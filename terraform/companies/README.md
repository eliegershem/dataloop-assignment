# Company Environments

This directory contains the infrastructure configurations for different companies. Each company has its own directory with environment-specific configurations.

## Directory Structure

```
companies/
├── company-name/              # Company-specific directory
│   ├── environments/         # Environment configurations
│   │   ├── dev/             # Development environment
│   │   ├── staging/         # Staging environment
│   │   └── prod/            # Production environment
│   ├── variables.tf         # Company-wide variables
│   └── terraform.tfvars     # Company-specific values
└── README.md                # This file
```

## Adding a New Company

1. Create a new directory for your company:
   ```bash
   mkdir -p companies/your-company/environments/{dev,staging,prod}
   ```

2. Copy the template files:
   ```bash
   cp -r companies/template/* companies/your-company/
   ```

3. Update the company-specific variables in:
   - `companies/your-company/variables.tf`
   - `companies/your-company/terraform.tfvars`

4. Configure environment-specific settings in:
   - `companies/your-company/environments/dev/main.tf`
   - `companies/your-company/environments/staging/main.tf`
   - `companies/your-company/environments/prod/main.tf`

## Company Configuration

Each company should define the following in their `variables.tf`:

- Company name and identifier
- Cloud provider preferences
- Network configurations
- Security requirements
- Resource quotas and limits

## Environment Configuration

Each environment (dev/staging/prod) should define:

- Environment-specific variables
- Resource sizes and scaling
- Network policies
- Security groups
- Monitoring and logging configurations 