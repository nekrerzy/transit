.PHONY: validate plan clean fmt init check help

# Terraform validation and formatting
validate:
	terraform fmt -check
	terraform validate

# Format Terraform files
fmt:
	terraform fmt -recursive

# Initialize and validate
init:
	terraform init
	terraform validate

# Plan deployment (read-only)
plan:
	terraform plan

# Full workflow: format, validate, plan
check: fmt validate plan

# Help
help:
	@echo "Available commands:"
	@echo "  make init     - Initialize and validate Terraform"
	@echo "  make fmt      - Format Terraform files"
	@echo "  make validate - Validate Terraform configuration"
	@echo "  make plan     - Plan Terraform deployment (read-only)"
	@echo "  make check    - Run fmt, validate, and plan"
	@echo ""
	@echo "Note: apply/destroy commands excluded for security"