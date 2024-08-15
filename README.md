## pull-mirror-template

A template/branch for mirroring repositories not on GitHub.

### Setup

1. Create a new repository using this template.
2. Add a new Actions variable from repository settings called `PULL_MIRROR_URL` with value set as the URL of the git repository you are mirroring.
3. Trigger the action manually from the Actions tab.
4. Go to settings and change the default branch to the newly pushed branch.
