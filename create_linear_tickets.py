#!/usr/bin/env python3
"""
Script to create Linear tickets from LINEAR_TICKETS.md

Usage:
    export LINEAR_API_KEY=your_api_key
    python create_linear_tickets.py

Or:
    LINEAR_API_KEY=your_api_key python create_linear_tickets.py
"""

import os
import re
import json
import sys
from dataclasses import dataclass
from typing import Optional

# Check for required dependencies
try:
    import requests
except ImportError:
    print("Installing requests library...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "-q"])
    import requests


LINEAR_API_URL = "https://api.linear.app/graphql"


@dataclass
class Ticket:
    """Represents a Linear ticket"""
    title: str
    description: str
    priority: str  # High, Medium, Low
    ticket_type: str  # Feature, Technical, Documentation
    estimate: int  # Story points
    epic: str
    acceptance_criteria: list[str]


def get_api_key() -> str:
    """Get Linear API key from environment"""
    api_key = os.environ.get("LINEAR_API_KEY")
    if not api_key:
        print("ERROR: LINEAR_API_KEY environment variable not set!")
        print("\nTo set it:")
        print("  export LINEAR_API_KEY=your_linear_api_key")
        print("\nOr run as:")
        print("  LINEAR_API_KEY=your_key python create_linear_tickets.py")
        sys.exit(1)
    return api_key


def linear_query(api_key: str, query: str, variables: Optional[dict] = None) -> dict:
    """Execute a GraphQL query against the Linear API"""
    headers = {
        "Authorization": api_key,
        "Content-Type": "application/json",
    }
    
    payload = {"query": query}
    if variables:
        payload["variables"] = variables
    
    response = requests.post(LINEAR_API_URL, headers=headers, json=payload)
    response.raise_for_status()
    
    result = response.json()
    if "errors" in result:
        raise Exception(f"Linear API error: {result['errors']}")
    
    return result["data"]


def get_teams(api_key: str) -> list[dict]:
    """Get all teams the user has access to"""
    query = """
    query {
        teams {
            nodes {
                id
                name
                key
            }
        }
    }
    """
    data = linear_query(api_key, query)
    return data["teams"]["nodes"]


def get_labels(api_key: str, team_id: str) -> dict[str, str]:
    """Get labels for a team, returns dict of name -> id"""
    query = """
    query($teamId: String!) {
        team(id: $teamId) {
            labels {
                nodes {
                    id
                    name
                }
            }
        }
    }
    """
    data = linear_query(api_key, query, {"teamId": team_id})
    return {label["name"]: label["id"] for label in data["team"]["labels"]["nodes"]}


def create_label(api_key: str, team_id: str, name: str, color: str = "#6366f1") -> str:
    """Create a label and return its ID"""
    mutation = """
    mutation($input: IssueLabelCreateInput!) {
        issueLabelCreate(input: $input) {
            issueLabel {
                id
                name
            }
        }
    }
    """
    variables = {
        "input": {
            "teamId": team_id,
            "name": name,
            "color": color
        }
    }
    data = linear_query(api_key, mutation, variables)
    return data["issueLabelCreate"]["issueLabel"]["id"]


def create_issue(api_key: str, team_id: str, title: str, description: str, 
                 priority: int = 0, estimate: int = 0, label_ids: list[str] = None) -> dict:
    """Create a Linear issue"""
    mutation = """
    mutation($input: IssueCreateInput!) {
        issueCreate(input: $input) {
            success
            issue {
                id
                identifier
                title
                url
            }
        }
    }
    """
    
    input_data = {
        "teamId": team_id,
        "title": title,
        "description": description,
        "priority": priority,
        "estimate": estimate,
    }
    
    if label_ids:
        input_data["labelIds"] = label_ids
    
    data = linear_query(api_key, mutation, {"input": input_data})
    return data["issueCreate"]["issue"]


def parse_tickets_from_markdown(filepath: str) -> list[Ticket]:
    """Parse LINEAR_TICKETS.md and extract all tickets"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    tickets = []
    current_epic = ""
    
    # Find all epics and their tickets
    epic_pattern = r"## Epic \d+: (.+?)(?=\n)"
    ticket_pattern = r"### Ticket [\d.]+: (.+?)(?=\n)"
    
    # Split by epics
    epic_sections = re.split(r"## Epic \d+:", content)
    epic_names = re.findall(epic_pattern, content)
    
    for i, epic_name in enumerate(epic_names):
        if i + 1 < len(epic_sections):
            epic_content = epic_sections[i + 1]
            
            # Find all tickets in this epic
            ticket_blocks = re.split(r"### Ticket [\d.]+:", epic_content)
            ticket_titles = re.findall(r"### Ticket [\d.]+: (.+?)(?=\n)", epic_content)
            
            for j, title in enumerate(ticket_titles):
                if j + 1 < len(ticket_blocks):
                    block = ticket_blocks[j + 1]
                    
                    # Extract priority
                    priority_match = re.search(r"\*\*Priority:\*\*\s*(\w+)", block)
                    priority = priority_match.group(1) if priority_match else "Medium"
                    
                    # Extract type
                    type_match = re.search(r"\*\*Type:\*\*\s*(\w+)", block)
                    ticket_type = type_match.group(1) if type_match else "Feature"
                    
                    # Extract estimate
                    estimate_match = re.search(r"\*\*Estimate:\*\*\s*(\d+)", block)
                    estimate = int(estimate_match.group(1)) if estimate_match else 1
                    
                    # Extract description
                    desc_match = re.search(r"\*\*Description:\*\*\s*\n(.+?)(?=\*\*Acceptance Criteria)", block, re.DOTALL)
                    description = desc_match.group(1).strip() if desc_match else ""
                    
                    # Extract acceptance criteria
                    ac_match = re.search(r"\*\*Acceptance Criteria:\*\*\s*\n(.+?)(?=---|$)", block, re.DOTALL)
                    acceptance_criteria = []
                    if ac_match:
                        ac_text = ac_match.group(1)
                        acceptance_criteria = re.findall(r"- \[ \] (.+)", ac_text)
                    
                    tickets.append(Ticket(
                        title=title.strip(),
                        description=description,
                        priority=priority,
                        ticket_type=ticket_type,
                        estimate=estimate,
                        epic=epic_name.strip(),
                        acceptance_criteria=acceptance_criteria
                    ))
    
    return tickets


def priority_to_int(priority: str) -> int:
    """Convert priority string to Linear priority integer (0=none, 1=urgent, 2=high, 3=medium, 4=low)"""
    mapping = {
        "Urgent": 1,
        "High": 2,
        "Medium": 3,
        "Low": 4
    }
    return mapping.get(priority, 0)


def get_label_color(label_type: str) -> str:
    """Get a color for a label type"""
    colors = {
        "Feature": "#22c55e",      # Green
        "Technical": "#3b82f6",    # Blue
        "Documentation": "#f59e0b", # Orange
        "High": "#ef4444",         # Red
        "Medium": "#f59e0b",       # Orange
        "Low": "#6b7280",          # Gray
    }
    return colors.get(label_type, "#6366f1")  # Default purple


def main():
    print("=" * 60)
    print("Linear Ticket Creator for Word of the Day App")
    print("=" * 60)
    
    # Get API key
    api_key = get_api_key()
    print("✓ API key found")
    
    # Get teams
    print("\nFetching teams...")
    teams = get_teams(api_key)
    
    if not teams:
        print("ERROR: No teams found. Make sure your API key has access to a team.")
        sys.exit(1)
    
    print(f"\nAvailable teams:")
    for i, team in enumerate(teams):
        print(f"  {i + 1}. {team['name']} ({team['key']})")
    
    # Select team
    if len(teams) == 1:
        selected_team = teams[0]
        print(f"\nUsing team: {selected_team['name']}")
    else:
        while True:
            try:
                choice = int(input("\nSelect team number: ")) - 1
                if 0 <= choice < len(teams):
                    selected_team = teams[choice]
                    break
                print("Invalid choice, try again.")
            except ValueError:
                print("Please enter a number.")
    
    team_id = selected_team["id"]
    
    # Parse tickets from markdown
    print("\nParsing LINEAR_TICKETS.md...")
    tickets = parse_tickets_from_markdown("LINEAR_TICKETS.md")
    print(f"✓ Found {len(tickets)} tickets")
    
    # Get/create labels
    print("\nSetting up labels...")
    existing_labels = get_labels(api_key, team_id)
    
    needed_labels = {"Feature", "Technical", "Documentation"}
    for label_name in needed_labels:
        if label_name not in existing_labels:
            print(f"  Creating label: {label_name}")
            existing_labels[label_name] = create_label(
                api_key, team_id, label_name, get_label_color(label_name)
            )
        else:
            print(f"  ✓ Label exists: {label_name}")
    
    # Create tickets
    print(f"\n{'=' * 60}")
    print("Creating {len(tickets)} tickets...")
    print(f"{'=' * 60}\n")
    
    created = 0
    failed = 0
    
    for ticket in tickets:
        # Format description with acceptance criteria
        full_description = f"**Epic:** {ticket.epic}\n\n"
        full_description += ticket.description + "\n\n"
        
        if ticket.acceptance_criteria:
            full_description += "**Acceptance Criteria:**\n"
            for ac in ticket.acceptance_criteria:
                full_description += f"- [ ] {ac}\n"
        
        # Get label ID for ticket type
        label_ids = []
        if ticket.ticket_type in existing_labels:
            label_ids.append(existing_labels[ticket.ticket_type])
        
        try:
            issue = create_issue(
                api_key=api_key,
                team_id=team_id,
                title=ticket.title,
                description=full_description,
                priority=priority_to_int(ticket.priority),
                estimate=ticket.estimate,
                label_ids=label_ids
            )
            print(f"✓ Created: {issue['identifier']} - {ticket.title}")
            print(f"  URL: {issue['url']}")
            created += 1
        except Exception as e:
            print(f"✗ Failed: {ticket.title}")
            print(f"  Error: {str(e)}")
            failed += 1
    
    # Summary
    print(f"\n{'=' * 60}")
    print("Summary")
    print(f"{'=' * 60}")
    print(f"✓ Created: {created}")
    print(f"✗ Failed: {failed}")
    print(f"Total: {len(tickets)}")


if __name__ == "__main__":
    main()
