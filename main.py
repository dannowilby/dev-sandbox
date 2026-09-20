import sys
from pathlib import Path

from k8s_agent_sandbox import SandboxClient
from k8s_agent_sandbox.models import SandboxLocalTunnelConnectionConfig


def print_help():
    print("Explanation of how to use the command")

"""
main.py <command> <name>
"""
def main():

    if len(sys.argv) != 3:
        print_help()
        return

    if sys.argv[1] == "create":
        create_sandbox(sys.argv[2])
        return

    if sys.argv[1] == "delete":
        delete_sandbox(sys.argv[2])
        return

def create_sandbox(name):

    box = Path(name + ".id.txt")

    if box.exists():
        return    

    print("Creating dev environment", name)

    client = SandboxClient(
        connection_config=SandboxLocalTunnelConnectionConfig()
    )

    sandbox = client.create_sandbox(
        warmpool="sandbox-warmpool",
        namespace="default",
    )

    claim_file_name = name + ".claim.txt"
    with open(claim_file_name, 'w') as fd:
        fd.write(sandbox.claim_name)

    pod_file_name = name + ".id.txt"
    with open(pod_file_name, 'w') as fd:
        fd.write(sandbox.sandbox_id)


def delete_sandbox(name):
    print("Deleting dev environment", name)

    client = SandboxClient(
        connection_config=SandboxLocalTunnelConnectionConfig()
    )

    try:
        sandbox = client.get_sandbox(
            claim_name=name,
            resolve_timeout=2
        )
        sandbox.terminate()
    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()
