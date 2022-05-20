# Pull Request Checklist Details

Here are some useful questions to ask before merging a Pull Request.

## [Security](https://cultureamp.atlassian.net/wiki/spaces/SEC/pages/963641883/Security+Partnership+Process)
- [Do we need an AppSec review?](https://cultureamp.atlassian.net/servicedesk/customer/portal/5/group/39/create/461)
- Have we modified authentication, authorization, filtering?
- Could there be any PII leaks through tracking or logging?
  
## Acceptance Criteria
- What is the acceptance criteria?
- How can we verify the PR has the desired effect?
- Are we sure there are no undesired side effects?
  
## Tests
- Do we have appropriate tests?
- How much of the new code do they cover?
- What gaps do you need to call out?

## Logging
- Are we logging the right things?
- Are we using structured logging?

## Involve Others
- [Do we need a Change Management Request?](https://cultureamp.atlassian.net/servicedesk/customer/portal/30)
- Does the tech lead need to see this?
- Do other teams need to see this?
