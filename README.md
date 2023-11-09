# icebird-spark

Spark @ CLO
Run a local spark cluster with AWS integrations.

# Docker Setup

## Prerequisites

Before you begin, ensure you have the following prerequisites installed and configured:

- **Docker**: Please follow the [Docker installation guide](https://docs.docker.com/get-docker/).
- **AWS CLI**: Ensure AWS CLI is installed and configured for SSO. Follow the [AWS CLI configuration guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).
- **`aws-sso-creds` utility**: Helper utility for managing AWS SSO credentials. [repo](https://github.com/jaxxstorm/aws-sso-creds).

## Configuration

To interact with AWS services from within the Spark cluster the following environment variables must set:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`

These credentials are necessary for Spark executors to authenticate with AWS services.

### Setting up AWS SSO 

If you are using AWS Single Sign-On (SSO), export temporary credentials via the `aws-sso-creds` utility. 

```sh
aws sso login --profile your-aws-sso-profile
eval $(aws-sso-creds export)
```

