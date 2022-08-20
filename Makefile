
TERRAFORM_IMAGE		:="hashicorp/terraform:1.2.7"
RUN_TERRAFORM		:=docker run -it --rm --env-file=.secrets.env -v $(PWD):$(PWD) -w $(PWD) $(TERRAFORM_IMAGE)

environment.tfvars:
	touch environment.tfvars

.secrets.env:
	echo "AWS_SECRET_ACCESS_KEY=" >> .secrets.env
	echo "AWS_ACCESS_KEY_ID=" >> .secrets.env
	echo "PAVLOV_KEY=" >> .secrets.env
	echo "Please fill in the values in .secrets.env"

fmt: .secrets.env
	$(RUN_TERRAFORM) fmt -diff -recursive
.PHONY: fmt

plan: .secrets.env environment.tfvars
	$(RUN_TERRAFORM) plan -var-file=environment.tfvars -out=.terraform.plan
.PHONY: plan

apply: .secrets.env
	$(RUN_TERRAFORM) apply .terraform.plan
.PHONY: apply

init: .secrets.env environment.tfvars
	$(RUN_TERRAFORM) init  -var-file=environment.tfvars
.PHONY: init

destroy: environment.tfvars
	$(RUN_TERRAFORM) destroy -var-file=environment.tfvars
.PHONY: destroy

output:
	$(RUN_TERRAFORM) output -json
.PHONY: output