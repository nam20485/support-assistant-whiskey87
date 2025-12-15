# Dockerized dynamic workflow agents

Use a branch and PR to:

Implement running instances of this template repo in docker containers as dynamic workflow agents. The goal is to run this repo in a docker container by using the .workflow/prompt.sh script as the entrypoint.

Use the  "ghcr.io/nam20485/agents-prebuild:main-latest" image as your base image.

Use a branch named `docker-agents` and open a PR against `main` when done.

Validate that the dockerized agents can run workflows as expected.

You will probably need to modify the `.workflow/prompt.sh` script to ensure it works correctly within a docker container environment.

One issue you may run into is authenticating the agent inside, when trying to start. The script uses opencode and claude. I was having more success with opencode.

 YOU MUST USE:
 1. THINKING.
 2. SEQUENTIAL_THINKING tool
 3. memory tool

- Research running Claude COE and opencode inside docker containers.
- Create a plan for the changes needed to dockerize the workflow agents.
- Once I approve you can proceed with the implementation.

- Validate the dockerized agents by running a sample workflow and ensuring it completes successfully.

- Do not declare success until you have validated the dockerized agents can run workflows as expected, using acceptance criteria you document in the plan.
