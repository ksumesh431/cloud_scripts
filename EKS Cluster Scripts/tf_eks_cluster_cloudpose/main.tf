module "vpc" {
    source = "./modules/vpc/"
    cidr_block = "10.0.0.0/16"
    namespace = "tixr"
    stage = "dev"
    region = "us-east-1"
}

module "eks" {
    source = "./modules/eks"
    vpc_cidr = "10.0.0.0/16"
    vpc_id = module.vpc.vpc_id
    max_size = 3
    min_size = 1
    desired_size = 1
    instance_types = ["t3.small"]
    region = "us-east-1"
    private_subnet_ids = module.vpc.private_subnet_ids
    security_group_ids = module.vpc.vpc_default_security_group_id
    kubernetes_namespace = "fargate-namespace"
    map_additional_iam_roles =  [ { userarn = "arn:aws:iam::895884664845:user/vvats",
                          username = "vvats",
                          groups: ["system:masters"]
                              }
                             ] 
}