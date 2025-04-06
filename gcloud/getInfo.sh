# Set project ID
PROJECT_ID="devlife4me-generic-apps"
REGION="us-central1"
SQL_INSTANCE_NAME="backend3-dev"  # <-- replace if different
VPC_CONNECTOR_NAME="backend3-connector-dev"
SERVICE_ACCOUNT_EMAIL="backend3-cloud-run-dev@$PROJECT_ID.iam.gserviceaccount.com"
CLOUD_RUN_SERVICE_NAME="backend3-service"

echo "==[ 1. SQL Instance Details ]=="
gcloud sql instances describe $SQL_INSTANCE_NAME --project=$PROJECT_ID

echo "==[ 2. VPC Connector Details ]=="
gcloud compute networks vpc-access connectors describe $VPC_CONNECTOR_NAME \
  --region=$REGION --project=$PROJECT_ID

echo "==[ 3. Cloud Run Service Environment Variables ]=="
gcloud run services describe $CLOUD_RUN_SERVICE_NAME \
  --region=$REGION --project=$PROJECT_ID \
  --format="flattened(spec.template.spec.containers[].env[])"

echo "==[ 4. Cloud Run Service Account IAM Roles ]=="
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:$SERVICE_ACCOUNT_EMAIL" \
  --format="table(bindings.role)"

echo "==[ 5. VPC Connector Subnet Routes List ]=="
gcloud compute routes list --filter="network:backend3-vpc-dev"

echo "==[ 6. Connector and SQL Subnet CIDR Ranges ]=="
gcloud compute networks subnets list --filter="network:backend3-vpc-dev" --format="table(name, region, ipCidrRange)"

echo "==[ 7. Firewall Rules ]=="
gcloud compute firewall-rules list --filter="network=backend3-vpc-dev"

echo "==[ 8. Verify Access to GCP APIs Through VPC ]=="
gcloud compute networks subnets describe connector-subnet-dev \
  --region=us-central1 \
  --project=devlife4me-generic-apps \
  --format="value(privateIpGoogleAccess)"
