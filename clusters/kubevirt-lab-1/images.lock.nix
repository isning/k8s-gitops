[
  {
    imageName = "adyanth/cloudflare-operator";
    imageDigest = "sha256:6b168dc237d50e3d36cc5df86bf2be7981700a49d7a4ae02548f4762ec0d7aaa";
    finalImageName = "adyanth/cloudflare-operator";
    finalImageTag = "0.13.1";
    archiveHash = "sha256-HWa6GLLiA0W8lKX+qJPnLRVDSJO2SxpO4HCd3S8eqp8=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cloudflare-operator-system"; name = "cloudflare-operator-controller-manager"; }
    ];
  }
  {
    imageName = "bitnami/kubectl";
    imageDigest = "sha256:a8373525af6a362dd256fd70ddd2492c6ac273eb745942dd0a22d318869269ee";
    finalImageName = "bitnami/kubectl";
    finalImageTag = "latest";
    archiveHash = "sha256-fmCEaNlTGWHTzv4mGdC072fQou0Jl46M8ngDmPTmh7I=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
    ];
  }
  {
    imageName = "busybox";
    imageDigest = "sha256:1487d0af5f52b4ba31c7e465126ee2123fe3f2305d638e7827681e7cf6c83d5e";
    finalImageName = "busybox";
    finalImageTag = "1.37.0";
    archiveHash = "sha256-Kv3m//FbfsZyfIisR3VDlADIKuMsOeFJOCNbgrO7wU8=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "napcat"; }
    ];
  }
  {
    imageName = "busybox";
    imageDigest = "sha256:1487d0af5f52b4ba31c7e465126ee2123fe3f2305d638e7827681e7cf6c83d5e";
    finalImageName = "busybox";
    finalImageTag = "latest";
    archiveHash = "sha256-mt7TgMZppgPb94aA2HtuTCmraPST56sscQezw4oqAYY=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-core";
    imageDigest = "sha256:32a13f6693a278261e9c9cb7eb606c5e2aa021308ae44fdc73225755048500a8";
    finalImageName = "docker.io/goharbor/harbor-core";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-nNTZRX0NmzWOjbbfrH0lhMmx/sMJ/hz2eqcAbkxiiZ0=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-core"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-jobservice";
    imageDigest = "sha256:a22c7cccba4673b26ffb96f5c37971d85d879dd837bc82448e01c0170b68cf28";
    finalImageName = "docker.io/goharbor/harbor-jobservice";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-vdBlE6o03AMyKZFex+4ixUewyNs5HnfomLZeh2jzFrQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-jobservice"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-portal";
    imageDigest = "sha256:541d5fa95bf77240d46a438f86245cdfd6afa6dd7fdd0cf4dd4c905af6a980b1";
    finalImageName = "docker.io/goharbor/harbor-portal";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-VzH5kZCEyzjPAfhMoO33rEF07AMRQVSzvWYitMrJVtk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-portal"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-registryctl";
    imageDigest = "sha256:463172f71d3a1e8d4f9e3b4e687a447f41fbc3126316d8c150dba04a903bbc47";
    finalImageName = "docker.io/goharbor/harbor-registryctl";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-JlHH1vtCji/X71u+EGO/YsCgWZxADPBGzbHUKS1gRAc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-registry"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/nginx-photon";
    imageDigest = "sha256:4fcfe831b1d99e3193a586e59ba4984ca2587a9b2998ccd433f8e9425beaabdc";
    finalImageName = "docker.io/goharbor/nginx-photon";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-K5id+5atGsEje3QNirm121ToAQ08AyO68RpCJ7/abdA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-nginx"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/registry-photon";
    imageDigest = "sha256:beb49fd16cf0906c04a2bf51a22f7210289e7cc2ae43a733e2a0364380aceae6";
    finalImageName = "docker.io/goharbor/registry-photon";
    finalImageTag = "v2.15.0";
    archiveHash = "sha256-EUOpLWDPyKaCYzujuQwP53SHGfIRp0QpRp+GWUEVkvc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-registry"; }
    ];
  }
  {
    imageName = "docker.io/istio/install-cni";
    imageDigest = "sha256:ffd908373e71733ac5ac5a55872191f57a41ddb6e9862f6e85fff768ed65ba2d";
    finalImageName = "docker.io/istio/install-cni";
    finalImageTag = "1.29.2-distroless";
    archiveHash = "sha256-JuEE+Rlc8UlqVMrm4W/uMCxhjlpXTbyXwokoJ/b0kik=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "istio-cni"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "istio-cni"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "istio-system"; name = "istio-cni-node"; }
    ];
  }
  {
    imageName = "docker.io/istio/pilot";
    imageDigest = "sha256:1378e20bee98ae325d8f3c3324b7f5f1dcc46a6d3ddeb701d2cafc8468f8e486";
    finalImageName = "docker.io/istio/pilot";
    finalImageTag = "1.29.2-distroless";
    archiveHash = "sha256-poaxxJaYBNQyj9TxE4Rp4LBMLZeuKGjrcQ5ofV9LsBw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "istiod"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "istiod"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "istio-system"; name = "istiod"; }
    ];
  }
  {
    imageName = "docker.io/istio/ztunnel";
    imageDigest = "sha256:3db3cd9e5426f8ac1bd7e8aaa9ad3edfe0b5045d19016d2e4378701354fc6640";
    finalImageName = "docker.io/istio/ztunnel";
    finalImageTag = "1.29.2";
    archiveHash = "sha256-if3zXllKvlAYJwIg62ZXOLMxWOkWSFq0KtWo3WWSRWg=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "ztunnel"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "ztunnel"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "istio-system"; name = "ztunnel"; }
    ];
  }
  {
    imageName = "docker.io/rancher/local-path-provisioner";
    imageDigest = "sha256:1eba82e9c386038b4af6d69cca7519fac738c28c42735ed48ce70c882ad0d80f";
    finalImageName = "docker.io/rancher/local-path-provisioner";
    finalImageTag = "v0.0.36";
    archiveHash = "sha256-X3RM4zooZTCz6KGDZX7HcN5AAInCeDdp3bXL2u0fQ0A=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "local-path-provisioner"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "local-path-provisioner"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kube-system"; name = "local-path-provisioner"; }
    ];
  }
  {
    imageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    imageDigest = "sha256:84518bf66f59d7eeb9afb760f79bb149ea6dce87d19d0478e24ce296c725f380";
    finalImageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    finalImageTag = "0.3.1";
    archiveHash = "sha256-nwUR0VKm3OhYwcScpdNwXkv0CQVl09k4+UFcXSTYZyU=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "bay"; }
    ];
  }
  {
    imageName = "ghcr.io/cloudnative-pg/cloudnative-pg";
    imageDigest = "sha256:0dfff19ba7b52ca25851a1010028b6940fff2e233290465af1cfb08a5f3f4661";
    finalImageName = "ghcr.io/cloudnative-pg/cloudnative-pg";
    finalImageTag = "1.29.1";
    archiveHash = "sha256-oxTYDItKuUanjATDRb7bKXVNTrvu/Oe1v5HiL1z7n3I=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cnpg-system"; name = "cnpg-cloudnative-pg"; }
    ];
  }
  {
    imageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    imageDigest = "sha256:2db19fa35b0ea2d9976a0a1429cccbc36bb37625457b5a7e3ce57f2221e6fd73";
    finalImageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    finalImageTag = "v0.48.0";
    archiveHash = "sha256-f/92JZtJLWiZmgroQiLXiPPy0bOuOqw/nVO/ULf3eYw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "flux-system"; name = "flux-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "flux-system"; name = "flux-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "flux-system"; name = "flux-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/flux-iac/tofu-controller";
    imageDigest = "sha256:e16d8295e66f73d66f6904a9129d8aedfa84612d1e8b5a8e122fda99d28af09c";
    finalImageName = "ghcr.io/flux-iac/tofu-controller";
    finalImageTag = "v0.16.3";
    archiveHash = "sha256-w66KKRcYzgqjatkguk4zTumSLazNqVmMS6d5qEFgiYQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "flux-system"; name = "tofu-controller"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "flux-system"; name = "tofu-controller"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "flux-system"; name = "tofu-controller"; }
    ];
  }
  {
    imageName = "ghcr.io/grafana/grafana-operator";
    imageDigest = "sha256:d45fc24e8f43d83286d81625ee8d919d0fc88255a6500b63f68d7966a4f9e9af";
    finalImageName = "ghcr.io/grafana/grafana-operator";
    finalImageTag = "v5.22.2";
    archiveHash = "sha256-Kgvz+UcqJ+teMSH+PUVfXi85uMwG7ZRGiQTGyO8PsZo=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "grafana-operator"; name = "grafana-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "grafana-operator"; name = "grafana-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "grafana-operator"; name = "grafana-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/isning/redroid-operator";
    imageDigest = "sha256:f5e367011b405a3b5c594a6821d8806b4990d09cdc91eae9e4983a106dc9142e";
    finalImageName = "ghcr.io/isning/redroid-operator";
    finalImageTag = "0.1.7";
    archiveHash = "sha256-SCsBrvqNkqHaZ3aUbcDe1ZYKN548zIyA2hBK+Qe0Sdw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "redroid-operator"; name = "redroid-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "redroid-operator"; name = "redroid-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "redroid-operator"; name = "redroid-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/kittors/clirelay";
    imageDigest = "sha256:8e885b164fc6735f8083c142644b71d98da7a77eeb2217bf25fd6967a4d83ddf";
    finalImageName = "ghcr.io/kittors/clirelay";
    finalImageTag = "main-de96948";
    archiveHash = "sha256-jHMpKFEKJDE31jRadQvgC8JxgBF4f38CzDwUSPo8dBA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "clirelay"; }
    ];
  }
  {
    imageName = "ghcr.io/logto-io/logto";
    imageDigest = "sha256:aa4c428b70d9dd8eac23b6eeb3826a02d5fe0283b5dd774589b9b9760e0c6e9f";
    finalImageName = "ghcr.io/logto-io/logto";
    finalImageTag = "1.38.0";
    archiveHash = "sha256-B67CsDo7rvNmSY3Bf4/Om1wMfKNh86OVjty1K1Ip7wk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "ghcr.io/sagernet/sing-box";
    imageDigest = "sha256:9bed1fcb406bd971d1b48c7f824e5128d63543ca278cdcd6b5737c19941e404d";
    finalImageName = "ghcr.io/sagernet/sing-box";
    finalImageTag = "v1.13.11";
    archiveHash = "sha256-Y/Cvm1O5wL1gInA8IdT3Fs5ccL49ZQRIjz+d/GdLuic=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "egress-system"; name = "proxy-engine"; }
    ];
  }
  {
    imageName = "ghcr.io/speaches-ai/speaches";
    imageDigest = "sha256:21e3df06d842fb7802ab470dd77c25f0e8c0d22950e8d8c6ae886e851af53ef8";
    finalImageName = "ghcr.io/speaches-ai/speaches";
    finalImageTag = "0.8.3-cpu";
    archiveHash = "sha256-D/3E3ks4e4fLtsR4Zbyjn4Y0HHLW6NxwXcuetjOkLpE=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "speaches"; }
    ];
  }
  {
    imageName = "mendhak/http-https-echo";
    imageDigest = "sha256:d072446da821a767d05dc19fa5ab6a27b1150bfb5c6ecfaecf3a2e5f9812794c";
    finalImageName = "mendhak/http-https-echo";
    finalImageTag = "40";
    archiveHash = "sha256-XxOU/bFguDeQ/tJ+MtEUWmuy5pQZewURjTHtEUOP3IA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "staging"; name = "echo"; }
    ];
  }
  {
    imageName = "mikefarah/yq";
    imageDigest = "sha256:0cb4a78491b6e62ee8a9bf4fbeacbd15b5013d19bc420591b05383a696315e60";
    finalImageName = "mikefarah/yq";
    finalImageTag = "4";
    archiveHash = "sha256-SA/l5kuN8TxOoS4SyxtXwiD1xcajllY1gyL4QlBMAkA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "napcat"; }
    ];
  }
  {
    imageName = "mlikiowa/napcat-docker";
    imageDigest = "sha256:bbb5da74f749ea8c11d2bd4b3623bf3b419a95c44a61bb09efe35ba628dafa73";
    finalImageName = "mlikiowa/napcat-docker";
    finalImageTag = "v4.18.1";
    archiveHash = "sha256-8vic/cfeB6BhEVedMiJy3nmMve7PFK1/Ke1qxrD1vUM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "napcat"; }
    ];
  }
  {
    imageName = "nginx";
    imageDigest = "sha256:5616878291a2eed594aee8db4dade5878cf7edcb475e59193904b198d9b830de";
    finalImageName = "nginx";
    finalImageTag = "mainline-alpine";
    archiveHash = "sha256-FWajmUxm7PsGXNh114QtQSMGWChUF4ZGActPyTyt6u4=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "i-reroute"; name = "i-reroute-proxy"; }
    ];
  }
  {
    imageName = "postgres";
    imageDigest = "sha256:09e4f20b14ddb3dfe3a0c825b206032aaf8f28300ba2070c0b60fc1c10c6abc7";
    finalImageName = "postgres";
    finalImageTag = "15-alpine";
    archiveHash = "sha256-lkyKe4HfswsfeNBVrEmbdWC/ELWX2ApGS0nIOi9KJxo=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "python";
    imageDigest = "sha256:dd4d2bd5b53d9b25a51da13addf2be586beebd5387e289e798e4083d94ca837a";
    finalImageName = "python";
    finalImageTag = "3.14-alpine";
    archiveHash = "sha256-n2xbA2XYajuOWMtlUIQwK9Ws0KpGE+eGpO0w2IfGiyM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "egress-system"; name = "proxy-engine"; }
    ];
  }
  {
    imageName = "quay.io/cilium/cilium";
    imageDigest = "sha256:2e61680593cddca8b6c055f6d4c849d87a26a1c91c7e3b8b56c7fb76ab7b7b10";
    finalImageName = "quay.io/cilium/cilium";
    finalImageTag = "v1.19.3";
    archiveHash = "sha256-Qq3O+9r+L9twOyKGENlpyS2pAGwYTBp6dcaNv1Kojxc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "kube-system"; name = "cilium"; }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-relay";
    imageDigest = "sha256:5ee21d57b6ef2aa6db67e603a735fdceb162454b352b7335b651456e308f681b";
    finalImageName = "quay.io/cilium/hubble-relay";
    finalImageTag = "v1.19.3";
    archiveHash = "sha256-8o3dFsvuzc5WgOAvt24Rb/m2lTxKu5b3Cb225yjs9X4=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kube-system"; name = "hubble-relay"; }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-ui-backend";
    imageDigest = "sha256:db1454e45dc39ca41fbf7cad31eec95d99e5b9949c39daaad0fa81ef29d56953";
    finalImageName = "quay.io/cilium/hubble-ui-backend";
    finalImageTag = "v0.13.3";
    archiveHash = "sha256-TXVwM4TW9RuTBCEg4xZv0XPgyZ2LjTAxUq9iutcX8lA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kube-system"; name = "hubble-ui"; }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-ui";
    imageDigest = "sha256:661d5de7050182d495c6497ff0b007a7a1e379648e60830dd68c4d78ae21761d";
    finalImageName = "quay.io/cilium/hubble-ui";
    finalImageTag = "v0.13.3";
    archiveHash = "sha256-8kFZpNhYS33s4pEoiH0ntfjU5pArpay6b2aXq8CriH8=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kube-system"; name = "hubble-ui"; }
    ];
  }
  {
    imageName = "quay.io/cilium/operator-generic";
    imageDigest = "sha256:205b09b0ed6accbf9fe688d312a9f0fcfc6a316fc081c23fbffb472af5dd62cd";
    finalImageName = "quay.io/cilium/operator-generic";
    finalImageTag = "v1.19.3";
    archiveHash = "sha256-n5ExlKsoVF3G8QTcRWWayWevMN2VVPHvXj4OpFlfAOo=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kube-system"; name = "cilium"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kube-system"; name = "cilium-operator"; }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-cainjector";
    imageDigest = "sha256:6f5a644135887b2aa7d5cc145072fa56421560e3586ff1f184358022d490f4e1";
    finalImageName = "quay.io/jetstack/cert-manager-cainjector";
    finalImageTag = "v1.20.2";
    archiveHash = "sha256-cK2Ky/L0T5fgRFky+dlSzYdOZ8b2vfazM1xJuvCFHZs=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cert-manager"; name = "cert-manager-cainjector"; }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-controller";
    imageDigest = "sha256:fe0623d7d04a382c888f03343a3a2da716e0d96ad3d5d790c0ebcbcb2a4329a5";
    finalImageName = "quay.io/jetstack/cert-manager-controller";
    finalImageTag = "v1.20.2";
    archiveHash = "sha256-OAqReEmEijER0+1X3Sj4sC4HdwWo8WSteUvFqAoEFH0=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-startupapicheck";
    imageDigest = "sha256:4e2a69b4a0cc9627905bbeecf720f95d5153ca39cacdab923d2748e73556792b";
    finalImageName = "quay.io/jetstack/cert-manager-startupapicheck";
    finalImageTag = "v1.20.2";
    archiveHash = "sha256-R564C0weL1kbdvVVuJMQJub2aAWqcr8ud6+lW57NyHQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "cert-manager"; name = "cert-manager-startupapicheck"; }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-webhook";
    imageDigest = "sha256:baf651128b9f05c426cbd5e60e2036bf382c99ca270f49d0757d6f7d2452f4e5";
    finalImageName = "quay.io/jetstack/cert-manager-webhook";
    finalImageTag = "v1.20.2";
    archiveHash = "sha256-NVq80oBYPWUoMYKR138WY8smbe+IVANV+L94yVaDMxs=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cert-manager"; name = "cert-manager-webhook"; }
    ];
  }
  {
    imageName = "quay.io/kiali/kiali-operator";
    imageDigest = "sha256:b0a733933bbcc7f4d36ab4aaf3134a51ff67d2215bdae4cecc0786840a6ad6f0";
    finalImageName = "quay.io/kiali/kiali-operator";
    finalImageTag = "v2.24.0";
    archiveHash = "sha256-ML//+eLpP/00s6RbVEDZ6aGVbZO9/esRqEK0y6pRemI=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kiali-operator"; name = "kiali"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kiali-operator"; name = "kiali"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kiali-operator"; name = "kiali-kiali-operator"; }
    ];
  }
  {
    imageName = "quay.io/kubevirt/cdi-operator";
    imageDigest = "sha256:42ce149c020523b466cd8cb5e413bad9800d93f502d82ced69a2d98a01944ce5";
    finalImageName = "quay.io/kubevirt/cdi-operator";
    finalImageTag = "v1.65.0";
    archiveHash = "sha256-Fdzy7PuNjuiHLz666LYSGo9P2mkeGqVbBEyYTFH6XzQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cdi"; name = "cdi-operator"; }
    ];
  }
  {
    imageName = "quay.io/kubevirt/cluster-network-addons-operator";
    imageDigest = "sha256:6d19b3d8a7b406fc4106f2b1ddbb5894884fba4fb854558e39d14e54e644f818";
    finalImageName = "quay.io/kubevirt/cluster-network-addons-operator";
    finalImageTag = "v0.102.0";
    archiveHash = "sha256-kjgD1fnKMUEDpkzGVWgT1YpAb1JS1NY/D29n4AuaUWc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cluster-network-addons"; name = "cluster-network-addons-operator"; }
    ];
  }
  {
    imageName = "quay.io/kubevirt/virt-operator";
    imageDigest = "sha256:a6cd48ee32c53fc09944cb1b3b709b8ef634f0168472b2409d1a31d0c345cbcb";
    finalImageName = "quay.io/kubevirt/virt-operator";
    finalImageTag = "v1.8.1";
    archiveHash = "sha256-R5oCaDN22ok32wjuEnrMTooQ+23NtH6UdcvTSTquaAU=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "kubevirt"; name = "virt-operator"; }
    ];
  }
  {
    imageName = "quay.io/oauth2-proxy/oauth2-proxy";
    imageDigest = "sha256:aa0bd8dd5ab0c78e4c91c92755ad573a5f92241f88138b4141b8ec803463b4fd";
    finalImageName = "quay.io/oauth2-proxy/oauth2-proxy";
    finalImageTag = "v7.15.2";
    archiveHash = "sha256-durlLR1fS8W30W9bxfVPCJ0MiC4prrUrUTM5+xTdtPw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "oauth2-proxy"; name = "oauth2-proxy"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "oauth2-proxy"; name = "oauth2-proxy"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "oauth2-proxy"; name = "oauth2-proxy"; }
    ];
  }
  {
    imageName = "rancher/kubectl";
    imageDigest = "sha256:05d2b313e2f397e0ade252136aed47abd72d56ead11d1b027ac70f66362c8495";
    finalImageName = "rancher/kubectl";
    finalImageTag = "v1.36.0";
    archiveHash = "sha256-tXf9CgCf3o7v15chhvFhjiY1iNQwDTwQ1vFebq/g3WY=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "CronJob"; namespace = "egress-system"; name = "proxy-engine-daily-restarter"; }
    ];
  }
  {
    imageName = "registry-1.docker.io/bitnami/redis-exporter";
    imageDigest = "sha256:839260c04bc3858980157da2f69219681bdcd8874fdb0a58c40b396050b5100d";
    finalImageName = "registry-1.docker.io/bitnami/redis-exporter";
    finalImageTag = "latest";
    archiveHash = "sha256-eHK7wwIosPA4v8fhhT94H5b6CTaZrKRChroMHzuVP7Y=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor-redis"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor-redis"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "StatefulSet"; namespace = "harbor"; name = "harbor-redis-master"; }
    ];
  }
  {
    imageName = "registry-1.docker.io/bitnami/redis";
    imageDigest = "sha256:1347d526ecec0c6537e99eac09e7c3405c21664f6044ff60e78b0898da37abd2";
    finalImageName = "registry-1.docker.io/bitnami/redis";
    finalImageTag = "latest";
    archiveHash = "sha256-+LTPen996/M0doQeJ8A4xHMTejzncEsLvpYf194B9Jk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor-redis"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor-redis"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "StatefulSet"; namespace = "harbor"; name = "harbor-redis-master"; }
    ];
  }
  {
    imageName = "registry.k8s.io/external-dns/external-dns";
    imageDigest = "sha256:f53faaf71cb270d1ca9dce6ea0c94bfebf1a18696263487f0fbc74b9bf2bd7ff";
    finalImageName = "registry.k8s.io/external-dns/external-dns";
    finalImageTag = "v0.21.0";
    archiveHash = "sha256-uw1knHdxvop/YQQ3+Wt86DRg2khnSabPnSl9USqk2kU=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "external-dns-system"; name = "external-dns"; }
    ];
  }
  {
    imageName = "registry.k8s.io/kube-state-metrics/kube-state-metrics";
    imageDigest = "sha256:1545919b72e3ae035454fc054131e8d0f14b42ef6fc5b2ad5c751cafa6b2130e";
    finalImageName = "registry.k8s.io/kube-state-metrics/kube-state-metrics";
    finalImageTag = "v2.18.0";
    archiveHash = "sha256-uZt3gz8sPY2JPc4taKnpXmKwg1IxxIpKAyPI8WWRkik=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack-kube-state-metrics"; }
    ];
  }
  {
    imageName = "registry.k8s.io/kubectl";
    imageDigest = "sha256:497d298f891edb7608dfce9dae4bb08dffc4ddcd7f5d24a0512d4bbf33e04f26";
    finalImageName = "registry.k8s.io/kubectl";
    finalImageTag = "v1.34.0";
    archiveHash = "sha256-mBa+lzGjFO8t6O7xB5wfrm7Woh1mRwaRXpmEIorvU0E=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack-victoria-metrics-operator-cleanup-hook"; }
    ];
  }
  {
    imageName = "soulter/astrbot";
    imageDigest = "sha256:b105ba78503525b678ef3f0f2801ef90338750970a264f2e6c72f83928082f4d";
    finalImageName = "soulter/astrbot";
    finalImageTag = "v4.24.2";
    archiveHash = "sha256-WP/imTFe/tD23TmQEE7Ynj3D4kw/jmMshgYdFf0LrCc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "astrbot"; }
    ];
  }
  {
    imageName = "squat/generic-device-plugin";
    imageDigest = "sha256:66c8d5c270eb2b721f1064c549b9b7898152a6d2f0163380a5d37dc7636c20ff";
    finalImageName = "squat/generic-device-plugin";
    finalImageTag = "0.2.0";
    archiveHash = "sha256-9EqfD65raGU+A03EysaiHlTgZoQ62DXvGA4prYGLu7k=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "kube-system"; name = "generic-device-plugin"; }
    ];
  }
  {
    imageName = "victoriametrics/operator";
    imageDigest = "sha256:8b637eaf5f8694ce7847a67b781f3e9a9df298eaa2c5d7fe6ff15cc3fd3f5bf6";
    finalImageName = "victoriametrics/operator";
    finalImageTag = "v0.69.0";
    archiveHash = "sha256-AGSAF/F9hxyMiZiLZxtm8+WxtysueIBA+lFUFk414Do=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack-victoria-metrics-operator"; }
    ];
  }
]
