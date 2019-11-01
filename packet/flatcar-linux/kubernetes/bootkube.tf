module "bootkube" {
  source = "github.com/kinvolk/terraform-render-bootkube?ref=7e9cf2460a3f01703f2edbfde463c1843fbf8d49"

  cluster_name = "${var.cluster_name}"

  # Cannot use cyclic dependencies on controllers or their DNS records
  api_servers          = ["${format("%s-private.%s", var.cluster_name, var.dns_zone)}"]
  api_servers_external = ["${format("%s.%s", var.cluster_name, var.dns_zone)}"]
  etcd_servers         = "${aws_route53_record.etcds.*.name}"
  asset_dir            = "${var.asset_dir}"
  networking           = "${var.networking}"
  network_mtu          = "${var.network_mtu}"

  # Select private Packet NIC by using the can-reach Calico autodetection option with the first
  # host in our private CIDR.
  network_ip_autodetection_method = "can-reach=${cidrhost(var.node_private_cidr, 1)}"

  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  enable_reporting      = "${var.enable_reporting}"
  enable_aggregation    = "${var.enable_aggregation}"

  certs_validity_period_hours = "${var.certs_validity_period_hours}"

  container_images = {
    calico           = "calico/node:v3.9.2"
    calico_cni       = "calico/cni:v3.9.2"
    # only amd64 images available for cloudnativelabs/kube-router
    hyperkube        = "k8s.gcr.io/hyperkube:v1.16.2"
    # coredns/coredns does not support an arch-specific tag for each version
    coredns          = "coredns/coredns:coredns-${var.os_arch}"
    pod_checkpointer = "kinvolk/pod-checkpointer:83e25e5968391b9eb342042c435d1b3eeddb2be1"
  }
}
