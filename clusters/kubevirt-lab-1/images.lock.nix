[
  {
    imageName = "adyanth/cloudflare-operator";
    imageDigest = "sha256:6b168dc237d50e3d36cc5df86bf2be7981700a49d7a4ae02548f4762ec0d7aaa";
    finalImageName = "adyanth/cloudflare-operator";
    finalImageTag = "0.13.1";
    hash = "sha256-zl2hbA0oVHgmT9vguQ934ashRjznU2nSQQTqKgEfrBs=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "bitnami/kubectl";
    imageDigest = "sha256:8affbdae5326dc4d3dab460a0ae70ee6ee47110d8294c5c0d9cdabcf43ca4a8c";
    finalImageName = "bitnami/kubectl";
    finalImageTag = "latest";
    hash = "sha256-VuVDROnZDEl+0jLpdiIUeAzPqwa3hZK/nu/KQppcWGk=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
      "prod";
    ];
    sources = [
      {
        namespace = "prod";
        kind = "HelmRelease";
        name = "logto";
      }
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "busybox";
    imageDigest = "sha256:1487d0af5f52b4ba31c7e465126ee2123fe3f2305d638e7827681e7cf6c83d5e";
    finalImageName = "busybox";
    finalImageTag = "1.37.0";
    hash = "sha256-uJjZL1+txeyHfM7tMgt6IUeX7c2KushI8QT1E36Dtmc=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "busybox";
    imageDigest = "sha256:1487d0af5f52b4ba31c7e465126ee2123fe3f2305d638e7827681e7cf6c83d5e";
    finalImageName = "busybox";
    finalImageTag = "latest";
    hash = "sha256-LJdlc+B/2oa11Kud1GdRsf5S3J3gNOxCTvEc5AqiGp0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "prod";
    ];
    sources = [
      {
        namespace = "prod";
        kind = "HelmRelease";
        name = "logto";
      }
    ];
  }
  {
    imageName = "docker.io/istio/install-cni";
    imageDigest = "sha256:88fb8849f6b2aa7343e36385b9adb3f4d9166a1f26432becee035997a0ac31cf";
    finalImageName = "docker.io/istio/install-cni";
    finalImageTag = "1.29.1-distroless";
    hash = "sha256-kESXROmAoqGh+sl//Ey/TlpvCiYsBnNTFN2tvMZadt0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "istio-system";
    ];
    sources = [
      {
        namespace = "istio-system";
        kind = "HelmRelease";
        name = "istio-cni";
      }
    ];
  }
  {
    imageName = "docker.io/istio/pilot";
    imageDigest = "sha256:80d6fcb2116aef065a8001ce055f55a6feac498c2aace222e637c7339c68cd56";
    finalImageName = "docker.io/istio/pilot";
    finalImageTag = "1.29.1-distroless";
    hash = "sha256-Rr68S2AePT+KaE7OFwoogEP6nZrKN5DWevRzskLOEuc=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "istio-system";
    ];
    sources = [
      {
        namespace = "istio-system";
        kind = "HelmRelease";
        name = "istiod";
      }
    ];
  }
  {
    imageName = "docker.io/istio/ztunnel";
    imageDigest = "sha256:5bf7a3561bd631b8add353468e738e2e4755f2ed8a10948eaffbe312f3d23f27";
    finalImageName = "docker.io/istio/ztunnel";
    finalImageTag = "1.29.1";
    hash = "sha256-OwNnmCzA3h0cyW1Pven7TfrK7Z2pvMe0eHcr5Udfka0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "istio-system";
    ];
    sources = [
      {
        namespace = "istio-system";
        kind = "HelmRelease";
        name = "ztunnel";
      }
    ];
  }
  {
    imageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    imageDigest = "sha256:84518bf66f59d7eeb9afb760f79bb149ea6dce87d19d0478e24ce296c725f380";
    finalImageName = "ghcr.io/astrbotdevs/shipyard-neo-bay";
    finalImageTag = "latest";
    hash = "sha256-guJ5jsg1FalGQTWqEMM6GkWpfSK+mV5R5YfV2mH/u/E=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "ghcr.io/cloudnative-pg/cloudnative-pg";
    imageDigest = "sha256:68074486205a33ed41928761e22ad48278c690feebe8316727a1c6b3380f9e5e";
    finalImageName = "ghcr.io/cloudnative-pg/cloudnative-pg";
    finalImageTag = "1.29.0";
    hash = "sha256-UWieKoPlh4RvK73QJcOC9+76kYzKruSsh5+uZZELVnU=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "cnpg-system";
    ];
    sources = [
      {
        namespace = "cnpg-system";
        kind = "HelmRelease";
        name = "cnpg";
      }
    ];
  }
  {
    imageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    imageDigest = "sha256:3e8f681fdfa64d076b5f67077bd81c6b9402c365d0e5e1def5382dece933b9e6";
    finalImageName = "ghcr.io/controlplaneio-fluxcd/flux-operator";
    finalImageTag = "v0.43.0";
    hash = "sha256-GJts3vBYyOyH+nJSM5c2KGVfaYX0vAYwr0lFkfv42Yg=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "HelmRelease";
        name = "flux-operator";
      }
    ];
  }
  {
    imageName = "ghcr.io/grafana/grafana-operator";
    imageDigest = "sha256:d45fc24e8f43d83286d81625ee8d919d0fc88255a6500b63f68d7966a4f9e9af";
    finalImageName = "ghcr.io/grafana/grafana-operator";
    finalImageTag = "v5.22.2";
    hash = "sha256-J88jET9uPCAJbPmLdash71MzA/4c+pEG827rUSis2ZE=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "grafana-operator";
    ];
    sources = [
      {
        namespace = "grafana-operator";
        kind = "HelmRelease";
        name = "grafana-operator";
      }
    ];
  }
  {
    imageName = "ghcr.io/isning/docker.io/mlikiowa/napcat-docker";
    imageDigest = "sha256:b98d613f25ec92ad90ca85a55105068e103fd8638595237e157efff433f5fba3";
    finalImageName = "ghcr.io/isning/docker.io/mlikiowa/napcat-docker";
    finalImageTag = "latest";
    hash = "sha256-sDJPnEk+aoT8EFw638ky3P/9RPGcJItsBUkiIYF3kxA=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "ghcr.io/isning/redroid-operator";
    imageDigest = "sha256:f5e367011b405a3b5c594a6821d8806b4990d09cdc91eae9e4983a106dc9142e";
    finalImageName = "ghcr.io/isning/redroid-operator";
    finalImageTag = "0.1.7";
    hash = "sha256-HN4uduyR6OArr7aG/lHx/ToOnGNsByOc/E0BbZ7Xb68=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "redroid-operator";
    ];
    sources = [
      {
        namespace = "redroid-operator";
        kind = "HelmRelease";
        name = "redroid-operator";
      }
    ];
  }
  {
    imageName = "ghcr.io/k8snetworkplumbingwg/multus-dynamic-networks-controller";
    imageDigest = "sha256:2a2bb32c0ea8b232b3dbe81c0323a107e8b05f8cad06704fca2efd0d993a87be";
    finalImageName = "ghcr.io/k8snetworkplumbingwg/multus-dynamic-networks-controller";
    finalImageTag = "latest";
    hash = "sha256-eAVu/iZmdVhvEQpsSPtm1J22LC0+UtwfmmzFCIxbasA=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "ghcr.io/kittors/clirelay";
    imageDigest = "sha256:4f7bf43f78ad751594d12ba3d00f075b25020a732c8d6bf8ff31daee70afa6be";
    finalImageName = "ghcr.io/kittors/clirelay";
    finalImageTag = "latest";
    hash = "sha256-Pq6trtpl0cvnGVB0GHu8kLQXtbmdMpRF3nNp5877DCs=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "ghcr.io/logto-io/logto";
    imageDigest = "sha256:aa4c428b70d9dd8eac23b6eeb3826a02d5fe0283b5dd774589b9b9760e0c6e9f";
    finalImageName = "ghcr.io/logto-io/logto";
    finalImageTag = "1.38.0";
    hash = "sha256-EERmVFATbtdb3DaY4IB9L1YXfhcFy8Q+P0QzmeQKkfs=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "prod";
    ];
    sources = [
      {
        namespace = "prod";
        kind = "HelmRelease";
        name = "logto";
      }
    ];
  }
  {
    imageName = "ghcr.io/sagernet/sing-box";
    imageDigest = "sha256:8772c662c8e349d3afb0c233ccc3864d7df69ce840d5aa25db4c248d5bcb44f7";
    finalImageName = "ghcr.io/sagernet/sing-box";
    finalImageTag = "v1.13.5";
    hash = "sha256-pVi72HFlsDLl414pPIDT56nyvNHNFeMtZhVSYUM7ONU=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "ghcr.io/speaches-ai/speaches";
    imageDigest = "sha256:21e3df06d842fb7802ab470dd77c25f0e8c0d22950e8d8c6ae886e851af53ef8";
    finalImageName = "ghcr.io/speaches-ai/speaches";
    finalImageTag = "latest-cpu";
    hash = "sha256-8goziYRspCXPHF9PGVV+4Bdf8EKXoQgYan0FsiFpDX0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "goharbor/harbor-core";
    imageDigest = "sha256:a30e5a8be3d94b6485e7fdd4ed7fdf9e9724ee0a6d103b3804aacf6784ee358e";
    finalImageName = "goharbor/harbor-core";
    finalImageTag = "v2.14.3";
    hash = "sha256-uQkEAdoIKXEQgcU3E+wWwBjrfu+ncSY+0eCwb3AEpwA=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/harbor-db";
    imageDigest = "sha256:93ea138ab491de8ff79401371db9ce843ba168cc8fa0d55974a464d75b696f6a";
    finalImageName = "goharbor/harbor-db";
    finalImageTag = "v2.14.3";
    hash = "sha256-ywLcy3oOUaTdyuWlybW6rfyYo+OJJ/oAI9kLxx6yt3M=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/harbor-jobservice";
    imageDigest = "sha256:e2b0298e894d725d68954b786c61c5dd607114f6129534756c8f7985124c07a6";
    finalImageName = "goharbor/harbor-jobservice";
    finalImageTag = "v2.14.3";
    hash = "sha256-ZwHaNk1dHTTSHMfLvnn7R1pJQpsHbet9f+DObhtH2+Y=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/harbor-portal";
    imageDigest = "sha256:2556b6c7dd832bf22ed8b177245fa5fbcd70255959e69c5d0fbe2153f4bd2243";
    finalImageName = "goharbor/harbor-portal";
    finalImageTag = "v2.14.3";
    hash = "sha256-1pBce12mcZjubGIj2DF+Bvo1nMGhy48/DlmWY5MVFgs=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/harbor-registryctl";
    imageDigest = "sha256:ddf6bb429eb6b5a3db3e98bfe6ab3dd2567ebb35547836d87fc54ddacebfac8d";
    finalImageName = "goharbor/harbor-registryctl";
    finalImageTag = "v2.14.3";
    hash = "sha256-HV8wL0shS04MW7DGk47kDfzImspy8alYMnHdDwZvyuc=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/nginx-photon";
    imageDigest = "sha256:e31b5290e31938fde76590e4f5d7b8eb3d8038ad1485879bdad7a480538dc858";
    finalImageName = "goharbor/nginx-photon";
    finalImageTag = "v2.14.3";
    hash = "sha256-lkNGHuKXeSfIXKpIhj2+wtf3gxR949P2K5lw6Hh582M=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/redis-photon";
    imageDigest = "sha256:f0e08db4909c21535667bd89676ac28c27003ca967830e259e3bd3aeb8e22f9c";
    finalImageName = "goharbor/redis-photon";
    finalImageTag = "v2.14.3";
    hash = "sha256-qnI2gD6HIgH8YNH1VQyYnhDT1gS9K1w3hGP9AE8AyzM=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "goharbor/registry-photon";
    imageDigest = "sha256:6533fc396cbce57131053faec55e1bd1da8b92aed318410c203ff1c7a9b910ab";
    finalImageName = "goharbor/registry-photon";
    finalImageTag = "v2.14.3";
    hash = "sha256-s1NxDzEjgYKAFRvIwPvbqeg4wnYbfEKagGimGX4bnpU=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "harbor";
    ];
    sources = [
      {
        namespace = "harbor";
        kind = "HelmRelease";
        name = "harbor";
      }
    ];
  }
  {
    imageName = "mendhak/http-https-echo";
    imageDigest = "sha256:8c1a7239d3bffe04ef89b1807fb17256ce7f242b61b315b28e2163d5e2aecaf0";
    finalImageName = "mendhak/http-https-echo";
    finalImageTag = "32";
    hash = "sha256-FfSV4h1dyHsPBIyS8mkdywnanwameGQrAu4zmd5zFu4=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "mikefarah/yq";
    imageDigest = "sha256:603ebff15eb308a05f1c5b8b7613179cad859aed3ec9fdd04f2ef5d32345950e";
    finalImageName = "mikefarah/yq";
    finalImageTag = "4";
    hash = "sha256-wvriDcQMZ30rLUwjzQAkZq/sTiwv/4+u9BRa99nPjsQ=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "nginx";
    imageDigest = "sha256:582c496ccf79d8aa6f8203a79d32aaf7ffd8b13362c60a701a2f9ac64886c93d";
    finalImageName = "nginx";
    finalImageTag = "mainline-alpine";
    hash = "sha256-SjvAkyqXaLDMIUJY8s/8HU1PNVmYuitTUQ3BId4TEbk=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-configs";
      }
    ];
  }
  {
    imageName = "postgres";
    imageDigest = "sha256:fceb6f86328c36f2438fae3b851b0cc57c4a7e69a58c866d9ce24281f2cf0c9c";
    finalImageName = "postgres";
    finalImageTag = "15-alpine";
    hash = "sha256-1g7d6yAuLKJVPbCRRiHniT1r7ya95grFw9k6tFvdvro=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "prod";
    ];
    sources = [
      {
        namespace = "prod";
        kind = "HelmRelease";
        name = "logto";
      }
    ];
  }
  {
    imageName = "python";
    imageDigest = "sha256:c99275d6bc0c37d8e98b388d4c404861fda7dad5ff87e2995fe7b7bb33898aed";
    finalImageName = "python";
    finalImageTag = "3.10-alpine";
    hash = "sha256-M3YcTJ6QVVuRZM1JAMDExOONsGj6b2JbHGBnSitcfII=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "quay.io/brancz/kube-rbac-proxy";
    imageDigest = "sha256:e6a323504999b2a4d2a6bf94f8580a050378eba0900fd31335cf9df5787d9a9b";
    finalImageName = "quay.io/brancz/kube-rbac-proxy";
    finalImageTag = "latest";
    hash = "sha256-+O+wEwPUkrMBh+zMSKNpypkUsoY9hEMEy6FaA//8das=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "quay.io/cilium/cilium";
    imageDigest = "sha256:7bc7e0be845cae0a70241e622cd03c3b169001c9383dd84329c59ca86a8b1341";
    finalImageName = "quay.io/cilium/cilium";
    finalImageTag = "v1.19.2";
    hash = "sha256-lXN5D2G9nuk3isd01SFoYY02ckjKAPcJ/zZqf3ibf9A=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "cilium";
      }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-relay";
    imageDigest = "sha256:9987c73bad48c987fd065185535fd15a6717cbe8a8caf7fc7ef0413532cf490e";
    finalImageName = "quay.io/cilium/hubble-relay";
    finalImageTag = "v1.19.2";
    hash = "sha256-7xR/tMwiGPtjwsXxHv/u5HFfCYcXkFxk1E4lXlIOSW8=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "cilium";
      }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-ui-backend";
    imageDigest = "sha256:db1454e45dc39ca41fbf7cad31eec95d99e5b9949c39daaad0fa81ef29d56953";
    finalImageName = "quay.io/cilium/hubble-ui-backend";
    finalImageTag = "v0.13.3";
    hash = "sha256-NZsXrJVdOx5pezgaW0FkkH2lswpkLsDGdv6OPjVoax0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "cilium";
      }
    ];
  }
  {
    imageName = "quay.io/cilium/hubble-ui";
    imageDigest = "sha256:661d5de7050182d495c6497ff0b007a7a1e379648e60830dd68c4d78ae21761d";
    finalImageName = "quay.io/cilium/hubble-ui";
    finalImageTag = "v0.13.3";
    hash = "sha256-p83b5NrzuWjRjs4FMrYAmOkQKUsc4EYCxv55cchF9Vg=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "cilium";
      }
    ];
  }
  {
    imageName = "quay.io/cilium/operator-generic";
    imageDigest = "sha256:e363f4f634c2a66a36e01618734ea17e7b541b949b9a5632f9c180ab16de23f0";
    finalImageName = "quay.io/cilium/operator-generic";
    finalImageTag = "v1.19.2";
    hash = "sha256-7w75MJ0AFGfRAzmg3beRea7b/lAE/dIr2wpgtmgyiE0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "cilium";
      }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-cainjector";
    imageDigest = "sha256:5d810724b177746a8aeafd5db111b55b72389861bcec03a6d50f9c6d56ec37c0";
    finalImageName = "quay.io/jetstack/cert-manager-cainjector";
    finalImageTag = "v1.19.4";
    hash = "sha256-T1N61mUjeAZ1e8JXQQjSnJ+vncYb++TcHHwDF7/S6es=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "cert-manager";
    ];
    sources = [
      {
        namespace = "cert-manager";
        kind = "HelmRelease";
        name = "cert-manager";
      }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-controller";
    imageDigest = "sha256:9cad8065bbf57815cbcfa813b903dd8822bcd0271f7443192082b54e96a55585";
    finalImageName = "quay.io/jetstack/cert-manager-controller";
    finalImageTag = "v1.19.4";
    hash = "sha256-Y62uJTWMBJam9SNgbA/3DK30SreMs4Ad69qDGTeVL/U=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "cert-manager";
    ];
    sources = [
      {
        namespace = "cert-manager";
        kind = "HelmRelease";
        name = "cert-manager";
      }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-startupapicheck";
    imageDigest = "sha256:8e897895b9e9749447ccb84842176212195f4687e0a3c4ca892d9d410e0fd43e";
    finalImageName = "quay.io/jetstack/cert-manager-startupapicheck";
    finalImageTag = "v1.19.4";
    hash = "sha256-MH60aRDXMGI33VmKDwEVFqHUBdPcGOyfvA8ISP0y32g=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "cert-manager";
    ];
    sources = [
      {
        namespace = "cert-manager";
        kind = "HelmRelease";
        name = "cert-manager";
      }
    ];
  }
  {
    imageName = "quay.io/jetstack/cert-manager-webhook";
    imageDigest = "sha256:f41b4ac798c8ff200c29756cf86e70a00e73fe489fb6ab80d9210d1b5f476852";
    finalImageName = "quay.io/jetstack/cert-manager-webhook";
    finalImageTag = "v1.19.4";
    hash = "sha256-o/D7ReLs3gAfdTbTb5Fdz7/vJ31ca0+tawnMsylpHvM=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "cert-manager";
    ];
    sources = [
      {
        namespace = "cert-manager";
        kind = "HelmRelease";
        name = "cert-manager";
      }
    ];
  }
  {
    imageName = "quay.io/kiali/kiali-operator";
    imageDigest = "sha256:b0a733933bbcc7f4d36ab4aaf3134a51ff67d2215bdae4cecc0786840a6ad6f0";
    finalImageName = "quay.io/kiali/kiali-operator";
    finalImageTag = "v2.24.0";
    hash = "sha256-OQtEE0NsmPFhLrc6SoTwhiD8dm+ZGfX2MKwvi6wxt8g=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kiali-operator";
    ];
    sources = [
      {
        namespace = "kiali-operator";
        kind = "HelmRelease";
        name = "kiali";
      }
    ];
  }
  {
    imageName = "quay.io/kubevirt/cdi-operator";
    imageDigest = "sha256:3a119a73bc1c9313a71289ff990eb87408cdd8a436925ef4656ecb5574127169";
    finalImageName = "quay.io/kubevirt/cdi-operator";
    finalImageTag = "v1.64.0";
    hash = "sha256-YKpZirzLyomsyEMqIUoSV1SYxCQ/pRf2e6zQQrtMYIY=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "quay.io/kubevirt/cluster-network-addons-operator";
    imageDigest = "sha256:3eab9642125d5b37de3283d40ae69f81b1ac89079332e36a2ac1296015bc429e";
    finalImageName = "quay.io/kubevirt/cluster-network-addons-operator";
    finalImageTag = "v0.101.2";
    hash = "sha256-JT6//fF6omOR82ZzJrDuiNXX6xpT6TSNYlFr36HHbGc=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "quay.io/kubevirt/virt-operator";
    imageDigest = "sha256:37d2ef21e3e5ea9590b9d5f26304ca8358e7a1787d6d73249c0b3ad8040e249c";
    finalImageName = "quay.io/kubevirt/virt-operator";
    finalImageTag = "v1.7.0";
    hash = "sha256-p1PZQqHV82rhhpD2L+FC/3eMKtiv628o+iMme77DjDg=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "quay.io/oauth2-proxy/oauth2-proxy";
    imageDigest = "sha256:39f08531587045a5443db43299bf8495696c99ed8d0e1fdcbe60534f7c02ce14";
    finalImageName = "quay.io/oauth2-proxy/oauth2-proxy";
    finalImageTag = "v7.15.1";
    hash = "sha256-fLOp2k0MVhLmqZZ+OKfBT3t7JXrusyCF0pdgcZRPqpU=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "oauth2-proxy";
    ];
    sources = [
      {
        namespace = "oauth2-proxy";
        kind = "HelmRelease";
        name = "oauth2-proxy";
      }
    ];
  }
  {
    imageName = "rancher/kubectl";
    imageDigest = "sha256:ff3cdadeac7eae628b59debe73302bb41337098dc3f15dfb3f3c5a59b046d23c";
    finalImageName = "rancher/kubectl";
    finalImageTag = "v1.34.0";
    hash = "sha256-Qh6QZ0X1aACeJHCz1w1MVm+0qEGXZigZ0eDJwMVxdcA=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "monitoring";
    ];
    sources = [
      {
        namespace = "monitoring";
        kind = "HelmRelease";
        name = "victoria-metrics-k8s-stack";
      }
    ];
  }
  {
    imageName = "rancher/local-path-provisioner";
    imageDigest = "sha256:6ff68ebe98bc623b45ad22c28be84f8a08214982710f3247d5862e9bccce73ef";
    finalImageName = "rancher/local-path-provisioner";
    finalImageTag = "v0.0.34";
    hash = "sha256-4gMpoTOHWF2NK8X01GuOvN6SBDDPsa+0q67KfAdl48c=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "kube-system";
    ];
    sources = [
      {
        namespace = "kube-system";
        kind = "HelmRelease";
        name = "local-path-provisioner";
      }
    ];
  }
  {
    imageName = "registry.k8s.io/external-dns/external-dns";
    imageDigest = "sha256:ddc7f4212ed09a21024deb1f470a05240837712e74e4b9f6d1f2632ff10672e7";
    finalImageName = "registry.k8s.io/external-dns/external-dns";
    finalImageTag = "v0.20.0";
    hash = "sha256-fZgKbdEPEx4ejmEbQ7INtXgudd7m7USGTUdf+ivXup0=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "registry.k8s.io/kube-state-metrics/kube-state-metrics";
    imageDigest = "sha256:1545919b72e3ae035454fc054131e8d0f14b42ef6fc5b2ad5c751cafa6b2130e";
    finalImageName = "registry.k8s.io/kube-state-metrics/kube-state-metrics";
    finalImageTag = "v2.18.0";
    hash = "sha256-7zJYcxg+KQtO20erjX5y9X1ymZdNSaJC8jiGnvRiS+s=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "monitoring";
    ];
    sources = [
      {
        namespace = "monitoring";
        kind = "HelmRelease";
        name = "victoria-metrics-k8s-stack";
      }
    ];
  }
  {
    imageName = "soulter/astrbot";
    imageDigest = "sha256:66c39096e34e1231a071a75812c884bb75fffc166a2e4c736878377a589ebfcf";
    finalImageName = "soulter/astrbot";
    finalImageTag = "latest";
    hash = "sha256-uzE5/jAbe5r22a5uX5Yokfv5LmesmC35WqhEfGUkMY8=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "apps";
      }
    ];
  }
  {
    imageName = "squat/generic-device-plugin";
    imageDigest = "sha256:c4e3a24a5f20449e027b9de2c3cee790169ab42220818315f5f8ee9830788981";
    finalImageName = "squat/generic-device-plugin";
    finalImageTag = "latest";
    hash = "sha256-fc3RACrMwKa85gil58Q/Lg7SFYeuTX6jDPTHPfbstwc=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "flux-system";
    ];
    sources = [
      {
        namespace = "flux-system";
        kind = "Kustomization";
        name = "infra-controllers";
      }
    ];
  }
  {
    imageName = "victoriametrics/operator";
    imageDigest = "sha256:f52e1bd679cb91ca81d92f606db61e6bed3ca66dfd69c631cc545b2b1567bcc6";
    finalImageName = "victoriametrics/operator";
    finalImageTag = "v0.68.3";
    hash = "sha256-IVsRx/6MozR9MwLtNsuAZkzQ3xH0BFaAbG8IHyuwhf4=";
    os = "linux";
    arch = "amd64";
    namespaces = [
      "monitoring";
    ];
    sources = [
      {
        namespace = "monitoring";
        kind = "HelmRelease";
        name = "victoria-metrics-k8s-stack";
      }
    ];
  }
]
