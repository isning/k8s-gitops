[
  {
    imageName = "adyanth/cloudflare-operator";
    imageDigest = "sha256:6b168dc237d50e3d36cc5df86bf2be7981700a49d7a4ae02548f4762ec0d7aaa";
    finalImageName = "docker.io/adyanth/cloudflare-operator";
    finalImageTag = "0.13.1";
    archiveHash = "sha256-UFLHLGTyi5CBy8SCcQyvLAJlPIiMLQKKog0DDIhKfno=";
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
    imageName = "b3log/siyuan";
    imageDigest = "sha256:1a316554bfbf0c951ddabc7d3cb0292620152b44c087b6979d5d9b6bae065b1b";
    finalImageName = "docker.io/b3log/siyuan";
    finalImageTag = "v3.6.5";
    archiveHash = "sha256-/5ID9aWzRCa9WASVLWrmSK4X3FzHAXwom3nKmYYDfVc=";
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
    imageDigest = "sha256:08afc880eea24f36572644ccae85fb3e573a6ff1b7161135a3ae9a5eab222df2";
    finalImageName = "docker.io/bitnami/kubectl";
    finalImageTag = "latest";
    archiveHash = "sha256-unLiLmjN9+Z5P4fLJ8appipH/yZ+ezUpG8Vm0EoPiIY=";
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
    imageDigest = "sha256:fd8d9aa63ba2f0982b5304e1ee8d3b90a210bc1ffb5314d980eb6962f1a9715d";
    finalImageName = "docker.io/library/busybox";
    finalImageTag = "latest";
    archiveHash = "sha256-6QfG5F03Lx3394n+pKmScYo3EF/JI+f/zQ2RFd5CxQI=";
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
    imageName = "cloudflare/cloudflared";
    imageDigest = "sha256:a5b5e6fd9a372f054b9a843c219bfbcdceb54691605312a8b1ee72978bdf1aa1";
    finalImageName = "docker.io/cloudflare/cloudflared";
    finalImageTag = "2026.5.1";
    archiveHash = "sha256-be95hm//BoLg3MfzD1tfWqCZF83U98agiP+Nl9Y2caA=";
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
    imageName = "docker.io/1467078763/metapi";
    imageDigest = "sha256:d29e74b18ce0734555c2088f1f6638e301a7fc01873ff979961ff8a1ac618da8";
    finalImageName = "docker.io/1467078763/metapi";
    finalImageTag = "latest";
    archiveHash = "sha256-g8Tmwah+ZgTtvRviqdhfICWyQA9MQw3zv2qCan6rU9c=";
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
    imageName = "docker.io/goharbor/harbor-core";
    imageDigest = "sha256:887a85b8ea98b76bfc9f715f1a0785bb99f9a1034241513902dd6e95be922a83";
    finalImageName = "docker.io/goharbor/harbor-core";
    finalImageTag = "v2.15.1";
    archiveHash = "sha256-i5Pz+Wo1eSSb7xxI0qWLvt9nY3x9DQ42BR2DaHj3t+g=";
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
    imageDigest = "sha256:0de4fd2ce3a02d3e6591b439e4674ea085885ddf43652b44004cc67eb19dba12";
    finalImageName = "docker.io/goharbor/harbor-jobservice";
    finalImageTag = "v2.15.1";
    archiveHash = "sha256-IOMWTPioMzuWYY7mOpQIWE1sDjJLplN6K4XPJl/JYBM=";
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
    imageDigest = "sha256:ac55161c57a8351807adf8f8def264bdd52667c371d0436beefebdac4341c9e2";
    finalImageName = "docker.io/goharbor/harbor-portal";
    finalImageTag = "v2.15.1";
    archiveHash = "sha256-6giFWh8hvKI8dv2kQFhPfgA1e3IwNmy7tqnuy8R48VQ=";
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
    imageDigest = "sha256:554147a956989175f63f8d41573d716c6ddf6052acd1749c88c0f99ce6ee2bff";
    finalImageName = "docker.io/goharbor/harbor-registryctl";
    finalImageTag = "v2.15.1";
    archiveHash = "sha256-0nar7lmPwn7aKXnL0vMbFHQGFERs6aYqfZgMRujw9Os=";
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
    imageDigest = "sha256:ebf0325c2661729dbb317cbf839608eb8b15cfa158911a94976f2c21563c466e";
    finalImageName = "docker.io/goharbor/registry-photon";
    finalImageTag = "v2.15.1";
    archiveHash = "sha256-VRXhI0dtdtmQgK1+gLLkY32dvoJLLZKVm93AhzgxuiQ=";
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
    imageDigest = "sha256:310c62b5e7ca5b08167e4384c68db0fd2905dd9c7493756d356e893909057601";
    finalImageName = "docker.io/library/alpine";
    finalImageTag = "3.22";
    archiveHash = "sha256-VHY3iJVzBNemI5WJ1BRfsfjOUDv6N/UZSJJYmoikFXI=";
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
    imageName = "docker.io/library/python";
    imageDigest = "sha256:dd4d2bd5b53d9b25a51da13addf2be586beebd5387e289e798e4083d94ca837a";
    finalImageName = "docker.io/library/python";
    finalImageTag = "3.14-alpine";
    archiveHash = "sha256-oXI5nXZgQsPL29gXKudeiMC1LBelnSdIiXRxzW2F2T4=";
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
      { kind = "Deployment"; namespace = "egress-system"; name = "proxy-engine"; }
    ];
  }
  {
    imageName = "docker.io/rancher/local-path-provisioner";
    imageDigest = "sha256:1eba82e9c386038b4af6d69cca7519fac738c28c42735ed48ce70c882ad0d80f";
    finalImageName = "docker.io/rancher/local-path-provisioner";
    finalImageTag = "v0.0.36";
    archiveHash = "sha256-7elybhSANToIiMssIKIFXidv1OlZ8o971VDwfNdKe9E=";
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
    imageName = "docker.io/vaultwarden/server";
    imageDigest = "sha256:d626d04934cd1192ad8ced1adb975099fca78cec33ab467d2d3c923cde7f3b0c";
    finalImageName = "docker.io/vaultwarden/server";
    finalImageTag = "1.36.0";
    archiveHash = "sha256-0nfPTInWIYZGyPwRRC1aYKAKC7jVQeRlIWe3HmyNzrE=";
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
    imageDigest = "sha256:84518bf66f59d7eeb9afb760f79bb149ea6dce87d19d0478e24ce296c725f380";
    finalImageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    finalImageTag = "0.3.1";
    archiveHash = "sha256-8vqHqtCJ2w1bMJsH8n63A23//BvADHCnkrJu9/eDFmY=";
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
    archiveHash = "sha256-xU71L4zdgfcXbZodsYIrYFnoMJxvCWaiZ1gdkEhocS4=";
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
    imageDigest = "sha256:0b9c428123313d93efbec26bdef85e91f2130a7bd8e382a767de12b3938f6271";
    finalImageName = "ghcr.io/cloudnative-pg/plugin-barman-cloud";
    finalImageTag = "v0.12.0";
    archiveHash = "sha256-W0glk+3dwzIHLJZ9XsIKXr494zBa6O+xZykwLLTKeug=";
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
    imageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    imageDigest = "sha256:d7423e1d6b0e206cc5b9758fa8615d7694664ed906c5087f4202eeb14187421a";
    finalImageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    finalImageTag = "v0.50.0";
    archiveHash = "sha256-WUndNOtEwGizy/ix1TK2YrJXfGWaOT6eqsDopVyW0u8=";
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
    imageName = "ghcr.io/headlamp-k8s/headlamp-plugin-cert-manager";
    imageDigest = "sha256:d7d0321a90c0347e2e4f9f7e362ecaa10a36592cc5ac8fd1514df11c476b43fe";
    finalImageName = "ghcr.io/headlamp-k8s/headlamp-plugin-cert-manager";
    finalImageTag = "v0.1.0";
    archiveHash = "sha256-K8fgubGpDrmeagg3nqTUnP9PN0SW77TLN2CcRTyc+m8=";
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
    imageName = "ghcr.io/headlamp-k8s/headlamp-plugin-flux";
    imageDigest = "sha256:055377b9011dcc73235e8969c488ecd92af5cb70aa5d5df0f66c1cea667fdccb";
    finalImageName = "ghcr.io/headlamp-k8s/headlamp-plugin-flux";
    finalImageTag = "v0.6.0";
    archiveHash = "sha256-4ADArqRNWx9gzmhBa9rpEYTJZJ14rY6N78bAi6wqZ8Y=";
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
    imageDigest = "sha256:c9754bae1d799220da0547e51ceee234f6e66ebadc138518ca73e33ecd331e59";
    finalImageName = "ghcr.io/headlamp-k8s/headlamp";
    finalImageTag = "v0.42.0";
    archiveHash = "sha256-NX0uuwxxZMwBHuJCWDhVvxgV8CO69j5y6ODttDP0vPg=";
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
        { kind = "Kustomization"; namespace = "flux-system"; name = "apps"; }
      ]
    ];
    targets = [
      { kind = "Deployment"; namespace = "unknown ns"; name = "logto"; }
      { kind = "Job"; namespace = "unknown ns"; name = "logto-pre-app-1"; }
    ];
  }
  {
    imageName = "ghcr.io/naval-group/headlamp-kubevirt";
    imageDigest = "sha256:7cdff58fdda4f3ad7b7a208b83744ec82648795056cf726f0ce5df2501ee3d14";
    finalImageName = "ghcr.io/naval-group/headlamp-kubevirt";
    finalImageTag = "0.2.2";
    archiveHash = "sha256-kF1hnipCHJmyujf3G8o1q/LtogrPKMDMW5jD1976rKk=";
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
      { kind = "Deployment"; namespace = "egress-system"; name = "proxy-engine"; }
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
    imageName = "postgres";
    imageDigest = "sha256:cd17e2ac98240fce1541ad2a803b34009b4eea5aec8a832363cdc7eca62e722e";
    finalImageName = "docker.io/library/postgres";
    finalImageTag = "15-alpine";
    archiveHash = "sha256-MyvOxet+UahaakhuiAQH8w3mfu81G7GwtQ/C+wETdrQ=";
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
        { kind = "Kustomization"; namespace = "flux-system"; name = "infra-controllers-networking"; }
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
    imageDigest = "sha256:d26eacf8aba492ae09ef781038ceea08a7c6f3bffbe222dbd8679ce642ed5c5f";
    finalImageName = "docker.io/soulter/astrbot";
    finalImageTag = "v4.25.1";
    archiveHash = "sha256-hZLSMXflPYk6asnT7QMfEOMTngH526t2oPJ9EbEBM0g=";
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
]
