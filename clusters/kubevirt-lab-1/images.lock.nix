[
  {
    imageName = "b3log/siyuan";
    imageDigest = "sha256:a2da59a722da6a2243f0c2a99286d9c8e73cc47dbc8757cc81ffd1137d6461a0";
    finalImageName = "docker.io/b3log/siyuan";
    finalImageTag = "v3.8.0";
    archiveHash = "sha256-2QocmGRS1+8sjqUTJntfYeXFSEhXfBoV7Htc67I8ED8=";
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
      { kind = "Deployment"; namespace = "prod"; name = "siyuan"; }
    ];
  }
  {
    imageName = "bitnami/kubectl";
    imageDigest = "sha256:999d5eb28f404b45f15117f2a110ff23c6164f76edac261d75d783b6e88252b7";
    finalImageName = "docker.io/bitnami/kubectl";
    finalImageTag = "latest";
    archiveHash = "sha256-91mUoFhsutpJjZHNyp+ScxbTZQ06MrVHalTFIUL+/co=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "logto"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
    ];
  }
  {
    imageName = "busybox";
    imageDigest = "sha256:b6762ddf4a50aabb5f4d21aa6f447d05d5633fb09f09c08b33f22356a2f98be0";
    finalImageName = "docker.io/library/busybox";
    finalImageTag = "1.38.0";
    archiveHash = "sha256-RFI1aj7Wkw6DESXiJn2mYp2+yqnsZa6LggATcpDH2dA=";
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
    imageDigest = "sha256:fd7dc98638c8e305f4dc34e979f1c0fdfdcaeb0fbf8fcff77ae834b6da3d7e6e";
    finalImageName = "docker.io/library/busybox";
    finalImageTag = "latest";
    archiveHash = "sha256-S7pcixHZLEIqTelFlxB9tiSEXA7f0e3myxdGW8aottg=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "logto"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "cloudflare/cloudflared";
    imageDigest = "sha256:9b49eed8f62806d5d45ddf59ecefb5710429598ea6d3fcccd2af938f621b2b07";
    finalImageName = "docker.io/cloudflare/cloudflared";
    finalImageTag = "2026.10.0";
    archiveHash = "sha256-D8se5AoLHhNiFK02M5ks7xhD/mx/7juhfOb1weh8TZ8=";
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
      { kind = "Deployment"; namespace = "cloudflare-operator-system"; name = "default-tunnel-v6"; }
    ];
  }
  {
    imageName = "docker.dragonflydb.io/dragonflydb/operator";
    imageDigest = "sha256:b11411142935f92ed0ec30a5ddeb31680e09ab66beecb827cb0224f1c4238638";
    finalImageName = "docker.dragonflydb.io/dragonflydb/operator";
    finalImageTag = "v1.6.1";
    archiveHash = "sha256-d4VjIAjgxAylnFnRP42WMKLZMNYa/ViiapofUJ/Tq8M=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-core";
    imageDigest = "sha256:d7b780d23721a000f0fb8e181add6675eafa336de5d033b77fd7da0c171ff7f7";
    finalImageName = "docker.io/goharbor/harbor-core";
    finalImageTag = "v2.15.2";
    archiveHash = "sha256-gJl3cIbcFQ/L0aoIssu461DLT9am50N2MH59WJ+nG4w=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-core"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-jobservice";
    imageDigest = "sha256:f71a4452a095bcd2a8f0683648a3ae28415432df87ccfb00ec7625f3e340a598";
    finalImageName = "docker.io/goharbor/harbor-jobservice";
    finalImageTag = "v2.15.2";
    archiveHash = "sha256-1GhkL6qvCcir/81B+oGmC+47liT1XvxuMUIPe5hoUuM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-jobservice"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-portal";
    imageDigest = "sha256:b811b67f7a7f6f1614e4bdf7478b207d13e8aa3f815ff6ad84f216a5098d213d";
    finalImageName = "docker.io/goharbor/harbor-portal";
    finalImageTag = "v2.15.2";
    archiveHash = "sha256-fzvPrQ3gq1zM+1i4ojoPHwEqL+pk4EGuo7NZ5Gd07uw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-portal"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/harbor-registryctl";
    imageDigest = "sha256:223d5cb49d5dbf0ba4ae022e7dd9775fa459904112dc12084d3aaa36c1408362";
    finalImageName = "docker.io/goharbor/harbor-registryctl";
    finalImageTag = "v2.15.2";
    archiveHash = "sha256-F4NXaic5YMhEl9Ek4TwRmfAuIc3oC+ryq6arLsUVw4U=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-registry"; }
    ];
  }
  {
    imageName = "docker.io/goharbor/registry-photon";
    imageDigest = "sha256:c4ebef61ceb50a3d8bc21d149bc280422db20a1e69df317b64b74098c3615855";
    finalImageName = "docker.io/goharbor/registry-photon";
    finalImageTag = "v2.15.2";
    archiveHash = "sha256-AtrCH/rKaBbPJvjxLn/Qlh1NLVMWmK5p3Dfusyrou7s=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "harbor"; name = "harbor"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "harbor"; name = "harbor-registry"; }
    ];
  }
  {
    imageName = "docker.io/helmforge/mc";
    imageDigest = "sha256:a7fe349ef4bd8521fb8497f55c6042871b2ae640607cf99d9bede5e9bdf11727";
    finalImageName = "docker.io/helmforge/mc";
    finalImageTag = "1.0.0";
    archiveHash = "sha256-8xPttbm6vhgjwnRXIxocms9wrClLTETa8bU31hrsC2s=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "CronJob"; namespace = "unknown ns"; name = "vaultwarden-vaultwarden-backup"; }
    ];
  }
  {
    imageName = "docker.io/library/alpine";
    imageDigest = "sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8";
    finalImageName = "docker.io/library/alpine";
    finalImageTag = "3.22";
    archiveHash = "sha256-x5XmGbSFw/vD8kUCUV0kVC+IuMv8I4J5SLlGQosI5pE=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "CronJob"; namespace = "unknown ns"; name = "vaultwarden-vaultwarden-backup"; }
    ];
  }
  {
    imageName = "docker.io/library/busybox";
    imageDigest = "sha256:bdf57e528e45e4433820e045b29b4597825a1c9e38353532d90a01445013f82e";
    finalImageName = "docker.io/library/busybox";
    finalImageTag = "1.37.0";
    archiveHash = "sha256-DazLrg/s7AZRihGdxdU1NFJqL8fYB0l5g7cwWylbUSM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "SandboxTemplate"; namespace = "agent-sandbox"; name = "restricted-shell"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "docker.io/library/python";
    imageDigest = "sha256:dd4d2bd5b53d9b25a51da13addf2be586beebd5387e289e798e4083d94ca837a";
    finalImageName = "docker.io/library/python";
    finalImageTag = "3.14-alpine";
    archiveHash = "sha256-oXI5nXZgQsPL29gXKudeiMC1LBelnSdIiXRxzW2F2T4=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "CronJob"; namespace = "kube-system"; name = "ipv6-pool-reconciler"; }
      { kind = "StatefulSet"; namespace = "egress-system"; name = "proxy-engine"; }
    ];
  }
  {
    imageName = "docker.io/rancher/local-path-provisioner";
    imageDigest = "sha256:e757967a5ec338f6a9b371c5a9688bedaa8c3578ea3dd4db329ea0084be0a86f";
    finalImageName = "docker.io/rancher/local-path-provisioner";
    finalImageTag = "v0.0.37";
    archiveHash = "sha256-1VMx0LPPFjmlMLITzN8fCSVrqZs98gIDfQ2DP6YA/eM=";
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
    imageName = "docker.io/squat/generic-device-plugin";
    imageDigest = "sha256:66c8d5c270eb2b721f1064c549b9b7898152a6d2f0163380a5d37dc7636c20ff";
    finalImageName = "docker.io/squat/generic-device-plugin";
    finalImageTag = "0.2.0";
    archiveHash = "sha256-Rx3V2OK8e5AoF8M/cRo01YiuyVvIPD5oqpRAUezDhN0=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "kube-system"; name = "generic-device-plugin"; }
    ];
  }
  {
    imageName = "docker.io/tencentcom/tencentcloud-cli";
    imageDigest = "sha256:6f2ac4dda0e903e8ada38b7a0abfaaf7609e99764e7748db0bd2b03e35d147f3";
    finalImageName = "docker.io/tencentcom/tencentcloud-cli";
    finalImageTag = "latest";
    archiveHash = "sha256-+W3xrG36BSyrrEmrOPqMdVFmtECJKD5POxPaQJAAGzA=";
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
      { kind = "CronJob"; namespace = "prod"; name = "coder-edgeone-certificate"; }
    ];
  }
  {
    imageName = "docker.io/vaultwarden/server";
    imageDigest = "sha256:1587c45feaa479f1f5e8af3b00eded36bff77bcf1880cf8dbf0541706dd470e0";
    finalImageName = "docker.io/vaultwarden/server";
    finalImageTag = "1.37.3";
    archiveHash = "sha256-Eux0fWCsGCdbM0g3B0RjJkj58G2YWUT+Pm50JoSqxuQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "vaultwarden"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "vaultwarden-vaultwarden"; }
    ];
  }
  {
    imageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    imageDigest = "sha256:4b03c51b77435e600c378f54e08d58f2b66f51397762a05b12d76d8d9547e414";
    finalImageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    finalImageTag = "0.4.0";
    archiveHash = "sha256-Xnaw33zywkoGy8E8VwIGvslmHy3OKkIQIGf4OItYTv4=";
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
    imageDigest = "sha256:923c267ec29636db3bee20f993d0ec4973fa22998e1adad37da79e4d32b5bc07";
    finalImageName = "ghcr.io/cloudnative-pg/cloudnative-pg";
    finalImageTag = "1.30.1";
    archiveHash = "sha256-GNlPjw+imF7qauAkHUDhF80SQ14nzO+NQ0QXBBJu234=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cnpg-system"; name = "cnpg-cloudnative-pg"; }
    ];
  }
  {
    imageName = "ghcr.io/cloudnative-pg/plugin-barman-cloud";
    imageDigest = "sha256:c75acad19a36e8176cfe2885761ff1b836c6ef977d7257e298c99a28b5c302ef";
    finalImageName = "ghcr.io/cloudnative-pg/plugin-barman-cloud";
    finalImageTag = "v0.15.1";
    archiveHash = "sha256-JtbAjTv2ofEoiPnxb9cyFuDtA8sV5JzHg7kU+YiK0WQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg-plugin-barman-cloud"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cnpg-system"; name = "cnpg-plugin-barman-cloud"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cnpg-system"; name = "cnpg-plugin-barman-cloud"; }
    ];
  }
  {
    imageName = "ghcr.io/coder/coder";
    imageDigest = "sha256:d28dd95045effa7e5cf55e96896362048be70991393d056e99271397d05f5a80";
    finalImageName = "ghcr.io/coder/coder";
    finalImageTag = "v2.34.7";
    archiveHash = "sha256-TuvixBnDwezUdxVc1PHBU999J4RTFUibBVhRepIV3q8=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "coder"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "coder"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "coder"; }
    ];
  }
  {
    imageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    imageDigest = "sha256:71041d9fff7f7b05f1a8123ebe73c73b7b156f4aacfe1e8e19b5aa953a98892c";
    finalImageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    finalImageTag = "v0.61.0";
    archiveHash = "sha256-mARFT4QhE05as8BSq9IsYTtqHDhppOccmhv0JYKz9bA=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "flux-system"; name = "flux-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "flux-system"; name = "flux-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "flux-system"; name = "flux-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/dragonflydb/dragonfly";
    imageDigest = "sha256:0fa01a2b929e704c7a9300d23e7f52002ebd39e90996fb8bb63826aed92fa06f";
    finalImageName = "ghcr.io/dragonflydb/dragonfly";
    finalImageTag = "v1.39.0";
    archiveHash = "sha256-iIDGqc3+JjQzLRviDZH4secv7tolk/CvSgA1BC/KNiI=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "ghcr.io/flux-iac/tofu-controller";
    imageDigest = "sha256:e16d8295e66f73d66f6904a9129d8aedfa84612d1e8b5a8e122fda99d28af09c";
    finalImageName = "ghcr.io/flux-iac/tofu-controller";
    finalImageTag = "v0.16.3";
    archiveHash = "sha256-gx5PoE785o3xUbtH1CekZj/BO2Vkxm8iqBv7ftGM1vQ=";
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
    imageDigest = "sha256:3abeaccdf54e9e02c2f4b6215be594c8f78b94a866961ada7f92b677bf33c9b4";
    finalImageName = "ghcr.io/grafana/grafana-operator";
    finalImageTag = "v5.23.0";
    archiveHash = "sha256-lJeZ0Xv3Sg3UUWJsniCgpU1r+kPmMmsf5dzpNdjiuMM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "grafana-operator"; name = "grafana-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "grafana-operator"; name = "grafana-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-monitoring"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "grafana-operator"; name = "grafana-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/headlamp-k8s/headlamp-plugin-flux";
    imageDigest = "sha256:636c7a5ae0d4eb196c192f8f1cde06f20f1f5ebdf1863f6e57d22444d8b8360c";
    finalImageName = "ghcr.io/headlamp-k8s/headlamp-plugin-flux";
    finalImageTag = "v0.7.0";
    archiveHash = "sha256-NFyK91FBfNwjstmo9lf9I1kLUacZ1zmXT8xkvs84u6g=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "ghcr.io/headlamp-k8s/headlamp";
    imageDigest = "sha256:b491653c1a0d380b70b67a4024f1204591f9c84a68ee567778d53d28b1856168";
    finalImageName = "ghcr.io/headlamp-k8s/headlamp";
    finalImageTag = "v0.44.0";
    archiveHash = "sha256-0UdhTpShId1t/kzQ3wCpTa9g2NvSWc3eMo5TC/7d2cM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "headlamp"; }
    ];
  }
  {
    imageName = "ghcr.io/isning/cloudflare-operator";
    imageDigest = "sha256:c04ced87671c54ad2c242d03eaba4d62298ab46bee571c71d5e136d8e192c87b";
    finalImageName = "ghcr.io/isning/cloudflare-operator";
    finalImageTag = "sha-123c94c";
    archiveHash = "sha256-1ZsoezdQwuOaOLAX/kabvk1O/th0Cu0uNGhUm4/boWM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "cloudflare-operator-system"; name = "cloudflare-operator-controller-manager"; }
    ];
  }
  {
    imageName = "ghcr.io/isning/k8s-gitops/tf-runner";
    imageDigest = "sha256:5c41d8a6c32df582bd61363febc10aef677042ad0497cdfca61db32c6459738e";
    finalImageName = "ghcr.io/isning/k8s-gitops/tf-runner";
    finalImageTag = "v0.16.3-custom-202605171200";
    archiveHash = "sha256-GXgWHsRBGOW/8w347z4etaGhl5+XYxCAukFImurQSHs=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "flux-system"; name = "tofu-controller"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "ghcr.io/isning/metapi";
    imageDigest = "sha256:18f0ab7173a197f0fa4d73662121b94098894417d3dbd15ae12afb0c3b22938b";
    finalImageName = "ghcr.io/isning/metapi";
    finalImageTag = "latest";
    archiveHash = "sha256-fp+DbodTjFPfwMxlJ4rmXxcbGLUSzl0iUmHGy3pp7xY=";
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
      { kind = "StatefulSet"; namespace = "prod"; name = "metapi"; }
    ];
  }
  {
    imageName = "ghcr.io/isning/redroid-operator";
    imageDigest = "sha256:f5e367011b405a3b5c594a6821d8806b4990d09cdc91eae9e4983a106dc9142e";
    finalImageName = "ghcr.io/isning/redroid-operator";
    finalImageTag = "0.1.7";
    archiveHash = "sha256-lQ/CZ7qBZ2hj8TQ7IwFrENloIcZ+9nFNlZJqCca4nZ0=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "redroid-operator"; name = "redroid-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "redroid-operator"; name = "redroid-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "redroid-operator"; name = "redroid-operator"; }
    ];
  }
  {
    imageName = "ghcr.io/logto-io/logto";
    imageDigest = "sha256:dabb2b3d087bb40fed8f33508ca16432ddf5c03f3e0846e36fe1f399a00ab1f3";
    finalImageName = "ghcr.io/logto-io/logto";
    finalImageTag = "1.40.1";
    archiveHash = "sha256-oFd5jZ9dNxupuqXmC0z1VXVFgr3bY5x4h1SgrNOQ3qI=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "logto"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "ghcr.io/naval-group/headlamp-kubevirt";
    imageDigest = "sha256:2e2102c52cef9318f15d07718a3ffcac91c54f2a2ef187c498c3f25b56cb657e";
    finalImageName = "ghcr.io/naval-group/headlamp-kubevirt";
    finalImageTag = "0.3.1";
    archiveHash = "sha256-y12pILMWDHlRa0lSmxYEmiCmBQCVSLMZWNOSr3EzzQE=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "ghcr.io/sagernet/sing-box";
    imageDigest = "sha256:da0e2331395c9025a85fa58892772b4cdbe5f2e530e93defeec3968175d06c6d";
    finalImageName = "ghcr.io/sagernet/sing-box";
    finalImageTag = "v1.13.12";
    archiveHash = "sha256-ADuYPHGPIlR6Krx0VT0TYSsuicKWKYDIv14IWvixPYk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "StatefulSet"; namespace = "egress-system"; name = "proxy-engine"; }
    ];
  }
  {
    imageName = "ghcr.io/speaches-ai/speaches";
    imageDigest = "sha256:21e3df06d842fb7802ab470dd77c25f0e8c0d22950e8d8c6ae886e851af53ef8";
    finalImageName = "ghcr.io/speaches-ai/speaches";
    finalImageTag = "0.8.3-cpu";
    archiveHash = "sha256-ft/OzpuyXj6FkI7KuVUkc8nTx0qC2ZziyueRZ7oBDcc=";
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
    imageName = "ghcr.io/the-ccsn/metacubexd";
    imageDigest = "sha256:703e33a8d6794db8e7cc4046d5eb4151674db085d9c9414a75f33b2845a980e1";
    finalImageName = "ghcr.io/the-ccsn/metacubexd";
    finalImageTag = "sha-81a1be9b191571cf395707b0e705bc28a4acde36";
    archiveHash = "sha256-JQ21UDP9fNhOmfAIvHEIZA7srEsqykM9INqVkfLyKfk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "egress-system"; name = "proxy-dashboard"; }
    ];
  }
  {
    imageName = "mendhak/http-https-echo";
    imageDigest = "sha256:d072446da821a767d05dc19fa5ab6a27b1150bfb5c6ecfaecf3a2e5f9812794c";
    finalImageName = "docker.io/mendhak/http-https-echo";
    finalImageTag = "40";
    archiveHash = "sha256-CgGyghmEZGpr4kDXsIdxcSCi73/dQxPRX88gg8aN8Io=";
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
    finalImageName = "docker.io/mikefarah/yq";
    finalImageTag = "4";
    archiveHash = "sha256-eNqpfndkEgc5r3MvnLfIiG+SIvAQt7Y1Qy/g/m4lyUM=";
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
    imageDigest = "sha256:2acfef8952da052ec66d8608e69db555c02e5ccc6e27e2609d641a2bee99be23";
    finalImageName = "docker.io/mlikiowa/napcat-docker";
    finalImageTag = "v4.18.4";
    archiveHash = "sha256-kvcajMl8ct+3dbDN1DEYsfzhCjC9zSRD9H7BQxX4gBM=";
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
    finalImageName = "docker.io/library/nginx";
    finalImageTag = "mainline-alpine";
    archiveHash = "sha256-IuU35fXh3ReyujqgasRzaL2WnSifc0kOQWBXNGSMv60=";
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
    imageName = "node";
    imageDigest = "sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1";
    finalImageName = "docker.io/library/node";
    finalImageTag = "24-alpine";
    archiveHash = "sha256-PAz8+pQR+T3kZ02JgnhFiY6Qi20LiQPAcGCkKA61Kug=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "headlamp"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "headlamp"; }
    ];
  }
  {
    imageName = "postgres";
    imageDigest = "sha256:f7d23353e1b15400d22ebe31189f4d314b87a4c129cc400c8c2d8d4ca127bf81";
    finalImageName = "docker.io/library/postgres";
    finalImageTag = "15-alpine";
    archiveHash = "sha256-7cpQSMWgGBZTgtv4Mkn+hhWV5OCxL8hzph/0yUZp6Jw=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "logto"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "logto"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "quay.io/brancz/kube-rbac-proxy";
    imageDigest = "sha256:ad0fa9f0adc928b557663297bd22c610533960d77acdec289ce8a636f0ea2114";
    finalImageName = "quay.io/brancz/kube-rbac-proxy";
    finalImageTag = "v0.20.2";
    archiveHash = "sha256-5iI3n2Y1tiZVcNANWOsZ35+Vg1+CbOZUDTEmZrjqeKo=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "dragonfly-operator-system"; name = "dragonfly-operator"; }
    ];
  }
  {
    imageName = "quay.io/cilium/cilium";
    imageDigest = "sha256:2eb67991eaa9368ba199c2fac2c573cb0ffdeb79184533344f42fc9a7ff6af3c";
    finalImageName = "quay.io/cilium/cilium";
    finalImageTag = "v1.19.4";
    archiveHash = "sha256-ryD/JBP9kzMo9MwtOynQBLsslXq+2aE4JvIZgZEztJY=";
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
    imageDigest = "sha256:59af8c0d561e560c2a042e7600a3496bc0367df8fbf868aa68d5834c8ec1a431";
    finalImageName = "quay.io/cilium/hubble-relay";
    finalImageTag = "v1.19.4";
    archiveHash = "sha256-A2JpV1AWc7sJFOReySU8+q0YKR7gZ3kBG5H+oeCQrFk=";
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
    imageDigest = "sha256:fac0c300ae119274edca11fd89b1ad23c788792d8bc4ea2ba631c709e8d3c688";
    finalImageName = "quay.io/cilium/hubble-ui-backend";
    finalImageTag = "v0.13.5";
    archiveHash = "sha256-kxiZjZ0IRaHo6dD/KG0QVcQYMFPdSELhUnB3Z5z12V0=";
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
    imageDigest = "sha256:f7d514fc54d784ed6df9d58cf0e97648b143f92b766dd1780ed3fc845bd4c516";
    finalImageName = "quay.io/cilium/hubble-ui";
    finalImageTag = "v0.13.5";
    archiveHash = "sha256-YL/QAcolkztR+e12y6NDv4c7ybuFDnnR6vqf4mmdEIg=";
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
    imageDigest = "sha256:1aa2b62735e7d8ab49ee840ae59c346932024c88901579121395c1271b435f71";
    finalImageName = "quay.io/cilium/operator-generic";
    finalImageTag = "v1.19.4";
    archiveHash = "sha256-v8gGpP3VvpRtqqlz1f6YKRI0yMPdTXxwIRYzOAwkjWA=";
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
    archiveHash = "sha256-tIBS8mb8WmVFgHvY5JK9Jr5uHSYJXv6+7XR37sKEkrE=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
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
    archiveHash = "sha256-gyNKBHUd4jXiApWt9lGDPoYk1bEd3U7mTgEXeHe9lE0=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
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
    archiveHash = "sha256-+DOo9Rd8WTG/FwVH/siYGJG3KeaW5NmsPv0lqchli8Y=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
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
    archiveHash = "sha256-S8jLxPAgf6Vy3EXfp3FtPG8JjG54d7POKK/No75QIvM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "cert-manager"; name = "cert-manager"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
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
    archiveHash = "sha256-1Y4lKoJ1aO4xnXG20P/sE7aTvgZlhv4JRRpHYPjieRM=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "kiali-operator"; name = "kiali"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "kiali-operator"; name = "kiali"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-identity-consumers"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-configs"; }
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
    archiveHash = "sha256-UssLI3sDgHU2ZMrBuP6Qwd+/YBo3M0XdrR1BvtIUZFQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
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
    archiveHash = "sha256-24svgvKbf6e7+0mChjclgg5RSuIBbUzxsAiK4pU/vGc=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
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
    archiveHash = "sha256-shEKhLfCGxc+pY+2bhN0zEPX9SQlw29zj8KqzRqXWjk=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
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
    archiveHash = "sha256-oMGYyqPjF5RyzlQ+x1+8VaFaC59YWBkuii79QtBpPOs=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "prod"; name = "oauth2-proxy"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "prod"; name = "oauth2-proxy"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "prod"; name = "oauth2-proxy"; }
    ];
  }
  {
    imageName = "rancher/kubectl";
    imageDigest = "sha256:05d2b313e2f397e0ade252136aed47abd72d56ead11d1b027ac70f66362c8495";
    finalImageName = "docker.io/rancher/kubectl";
    finalImageTag = "v1.36.0";
    archiveHash = "sha256-YpOd+xnsiOtSjzvNPDQEfQ0G6Vq1scg4udg3rQaTc0o=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "CronJob"; namespace = "egress-system"; name = "proxy-engine-daily-restarter"; }
    ];
  }
  {
    imageName = "registry.istio.io/release/install-cni";
    imageDigest = "sha256:c37347421fe4d99b34d193b79437e7186fda762b2ae8231f28e2b9add287b9b5";
    finalImageName = "registry.istio.io/release/install-cni";
    finalImageTag = "1.30.0-rc.0-distroless";
    archiveHash = "sha256-YHw4kFUcra/OgFPZCl0b4AYK9P9+P4yk8VQ+XI04uPY=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "istio-cni"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "istio-cni"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "istio-system"; name = "istio-cni-node"; }
    ];
  }
  {
    imageName = "registry.istio.io/release/pilot";
    imageDigest = "sha256:db64101f2e1828323950dc1bf12ed35bcf77121fc3cbb505bef31a5fb7dfe605";
    finalImageName = "registry.istio.io/release/pilot";
    finalImageTag = "1.30.0-rc.0-distroless";
    archiveHash = "sha256-jkLTtqhOt8OcIbqJeFk/Ogdx7PtnVWPd6G9fky3TUm8=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "istiod"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "istiod"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "istio-system"; name = "istiod"; }
    ];
  }
  {
    imageName = "registry.istio.io/release/proxyv2";
    imageDigest = "sha256:9ac03a22e3cbc83def63242c4609ddf5b3a7bdac9fa06fa815eb72611fd44616";
    finalImageName = "registry.istio.io/release/proxyv2";
    finalImageTag = "1.30.0-rc.0-distroless";
    archiveHash = "sha256-E0fv5Z0dL5eLpG9o57/36U30T2s0B7FqzSbiU0Hr0zQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "istio-base"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [];
  }
  {
    imageName = "registry.istio.io/release/ztunnel";
    imageDigest = "sha256:d2e1bdab8c85c335c173828a3fd34898a46fbb9139b409f646b4e8e4d328ad7e";
    finalImageName = "registry.istio.io/release/ztunnel";
    finalImageTag = "1.30.0-rc.0";
    archiveHash = "sha256-si/XGIUvSOAPwTd0GCezeiKxBDT2GnCNWrHuNNts5ws=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "istio-system"; name = "ztunnel"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "istio-system"; name = "ztunnel"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "DaemonSet"; namespace = "istio-system"; name = "ztunnel"; }
    ];
  }
  {
    imageName = "registry.k8s.io/agent-sandbox/agent-sandbox-controller";
    imageDigest = "sha256:28a9cbdbfd6ac0a4e5c7e9261ace1aa30ee2da681cb640dccdfed98e8dd9d98b";
    finalImageName = "registry.k8s.io/agent-sandbox/agent-sandbox-controller";
    finalImageTag = "v1.0.5";
    archiveHash = "sha256-dLRuso0541JS/ibzw9onWfrrGGXIecp5ACwtxG3ohBY=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "agent-sandbox-system"; name = "agent-sandbox"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "agent-sandbox-system"; name = "agent-sandbox"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-general"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "agent-sandbox-system"; name = "agent-sandbox-controller"; }
    ];
  }
  {
    imageName = "registry.k8s.io/external-dns/external-dns";
    imageDigest = "sha256:f53faaf71cb270d1ca9dce6ea0c94bfebf1a18696263487f0fbc74b9bf2bd7ff";
    finalImageName = "registry.k8s.io/external-dns/external-dns";
    finalImageTag = "v0.21.0";
    archiveHash = "sha256-K7UZeshz6Pe2nLWENwfOwleQY7s0dZbCt5h0RmqsEg4=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
    ];
    sourceChains = [
      [
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-foundation"; }
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
    archiveHash = "sha256-gSj8cOXfXbd3JZlbMcdCeX6m+StugUaLdO4uokNtPPo=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-monitoring"; }
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
    archiveHash = "sha256-7dOzMbF6gXpX6Bv65fVzW4DqLgpLgoGvZSIjYihmxEQ=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-monitoring"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Job"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack-victoria-metrics-operator-cleanup-hook"; }
    ];
  }
  {
    imageName = "soulter/astrbot";
    imageDigest = "sha256:e51e924d47c5921b9f92afd9c9bb1d459cb5eda33185b494515464f4b051d9bc";
    finalImageName = "docker.io/soulter/astrbot";
    finalImageTag = "v4.27.3";
    archiveHash = "sha256-0gEktCjT8S/5eu4chyGFEhwPlzW4Y3ucFK+jI0IrpgU=";
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
    imageName = "victoriametrics/operator";
    imageDigest = "sha256:fb5ebef9cba3746d73ee0dee1bb9e4bc80539687518fd1e2e6ab7776b438048a";
    finalImageName = "docker.io/victoriametrics/operator";
    finalImageTag = "v0.70.1";
    archiveHash = "sha256-rb277HtbVnGZMfd9U4tITUCPNzEo1Txwy4aRmSglDIY=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-monitoring"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "monitoring"; name = "victoria-metrics-k8s-stack-victoria-metrics-operator"; }
    ];
  }
  {
    imageName = "xpkg.crossplane.io/crossplane/crossplane";
    imageDigest = "sha256:cfa88491dca479686747ccd0f0d1888ec8a7d1ee34629f19d45f509d6995148b";
    finalImageName = "xpkg.crossplane.io/crossplane/crossplane";
    finalImageTag = "v2.4.2";
    archiveHash = "sha256-CWcxIa9PBFt+gIS/UvdoXhCwrQ/0nYX00n0k/Dh/bsU=";
    os = "linux";
    arch = "amd64";
    sources = [
      { kind = "HelmRelease"; namespace = "crossplane-system"; name = "crossplane"; }
    ];
    sourceChains = [
      [
        { kind = "HelmRelease"; namespace = "crossplane-system"; name = "crossplane"; }
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-pre-controllers"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "crossplane-system"; name = "crossplane"; }
      { kind = "Deployment"; namespace = "crossplane-system"; name = "crossplane-rbac-manager"; }
    ];
  }
]
