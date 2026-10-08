# ccsn commit 引入清单（最新 main 重新盘点）

分析日期：2026-10-08。本清单替代此前截至 2026-06-03 的 dev 清单。已按最新基线引入通用修复、依赖升级、bootstrap 和管理架构迁移；管理接管分阶段启用，尚未部署。

## 基线与选择原则

- 本地：`origin/main` = `b1cdec83b1e503f5dbd0aadcf70a65c6305749fc`，2026-10-06，包含最新 Vaultwarden SSO consent 修复。
- ccsn：直接从 GitHub 获取 `the-ccsn/k8s-gitops` 的默认分支 `main` = `22ff96a7cdc83baba9ded3c40dcfb2ffea0e4525`，2026-10-08。保存为本仓库的 `refs/remotes/ccsn/main`；没有读取工作区外的 ccsn 本地目录。
- 共同祖先：`3f2264128f7fda45033b555cba675dd2481b7c16`。
- `origin/main..ccsn/main` 共 **178 个提交**。旧 `ccsn/dev..ccsn/main` 有 115 个提交；旧 dev 末尾 3 个提交未进入 main，main 中有对应的另一组提交号，因此不能把旧清单简单追加。
- 按最终 tree、后续撤销/替换和本地已有能力筛选，而不是逐个照搬历史提交。
- 用户约束：规模较小，**不做 HA；不将 Vaultwarden 从 SQLite 迁至独立 PostgreSQL；保留现有 PostgreSQL 部署规模和本地存储方案**。
- 已适配 bootstrap 与 Cilium 共享 values。此前存在的两份未跟踪 Terraform lock 文件未改动。

## 相比旧清单，必须纠正的判断

| 旧实现 / 历史提交 | 最新实际状态 | 本地处理 |
| --- | --- | --- |
| Logto Bitnami Redis：`1e1042d`、`81d8ab3`、`ad9ff6f` 等 | `55f46a5` 已删除 `apps/base/logto/redis-release.yaml`，改 Dragonfly；Logto 多副本仍保留 | 不重建旧 Redis，也不引入 Logto HA/新增缓存服务 |
| Harbor Redis | `ed9576f` 已替换 Dragonfly；本地 `daf2f8b` 已引入此能力 | 不重复 pick，不还原 Redis |
| tofu-controller、runner 镜像/构建、Harbor Terraform 管理 | `3410c37` 已移除这些上游资源，改 Crossplane CRD 管理 | 只有迁移 CRD 管理时才移除本地旧资源，不能只 pick 删除部分 |
| 旧集群单一 networking 层 | `3410c37` 拆出 core networking，将 Kiali 等依赖身份的组件后移，并引入身份就绪依赖 | 如引入 CRD 管理，需一起适配依赖图，不混搭两套所有权 |
| Proxy 工作缓存 PVC / UI 与代理共处 | `3400053` 已删除 `work-cache-pvc.yaml`，新增原生 UI 与 mesh 授权、runtime config 隔离，同时引入两副本和 RWX | 只提取适合单实例的缓存、API 隔离和可选 UI 改进 |
| Headlamp Node runtime 临时 Google mirror | `d922ad4` 被 `1d6f915` 恢复；最新使用 `node:24-alpine` | 取最终配置，不重复搬运临时镜像变更 |
| Logto 本地 branding 静态服务 | `e9568bf` 被 `4326acf` 完整 revert，后来改 hosted logos | 不引入已删除的 branding Deployment/SVG，也不搬公司品牌 |
| DNS public fallback 绕过 OpenWrt UDP interception | `05ab252` 被最新 `22ff96a` 完整 revert | 两个提交均不引入 |
| bootstrap Terraform | **仍保留**，`dba5d9d` 主要完善文档，并未修正 main.tf/variables.tf | 仍可适配，但不能原样 pick：上游 string `bootstrap_revision=main` 与固定模块 0.7.0 的 number revision 不兼容 |

## 推荐引入的通用改进：7 个提交

这组与独立 PostgreSQL、HA 和园区业务无关。选择的是功能；涉及环境标识的 patch 仍需适配和验证。

| Commit | 改进 | 本地适配重点 |
| --- | --- | --- |
| `121f771` | Istio ambient detection 重试与 CNI Pod 重启触发 | 保留当前 chart/CNI 参数，annotation 用本地标识 |
| `ea91da7` | Flux Web 的 HBONE 15008 入站 NetworkPolicy | 本地 HelmRelease 仍在 pre-controllers；只加 policy，保留本地 OAuth Secret |
| `b06958a` | 节点指标 HTTPS + token/CA + 标签白名单 | 当前 VMNodeScrape 仍是 HTTP/全标签；保留近期 VictoriaMetrics 缓存预算，只按实际需要移除自定义 CA 挂载 |
| `ea9a1b2` | CONNECT ServiceEntry 使用 workloadSelector，保留代理 Pod 身份 | 本地 `app: proxy-engine` selector 可对应；不依赖 RWX/双副本，但需验证 mesh 路径 |
| `48350fd` | Headlamp 插件升级、cert-manager 插件安装、Renovate image volume 跟踪 | 本地 chart 是 **0.44.0**，ccsn 是 0.42.0，不能整份覆盖；保留本地 OIDC、digest pin 和禁用 automerge 策略 |
| `b7c46d3` | Headlamp plugin installer 使用集群出口代理 | 使用本地已存在的 proxy-svc，核对 Node runtime 的 proxy 环境变量支持 |
| `2ad9313` | 静态 OCI 插件与 installer 清理目录分离 | 与 `48350fd` 成组，采用最终 static-plugins 挂载路径 |

## 拆分适配：9 个提交

| Commit | 可取部分 | 排除或待验证部分 |
| --- | --- | --- |
| `3a6a311` | Cilium shared values，供 Flux 与 bootstrap 共用 | 不覆盖本地 L2、动态 IPv6、公网池 reconciler、BPF map budget 和单实例 operator |
| `b9465bd` | Terraform + Flux Operator bootstrap | 修正 revision 类型、API endpoint、provider 版本约束与 age Secret 编码；保留本地镜像/集群身份 |
| `dba5d9d` | NixOS 与 Kubernetes bootstrap 边界、阶段检查、恢复流程 | 不复制对方 nodes/VIP/BGP/Longhorn/identity 依赖；修正其中仍存在的 revision=main 示例 |
| `cefdf20` | 代理 public IPv4/IPv6 网络 profiles | campus profiles、对方网络地址和不必要监听端口不引入 |
| `3400053` | 缓存原子写入、runtime config 隔离、代理 API 保护、可选原生 UI | 两副本、Longhorn/RWX、共享存储设计不引入；原生 UI 依赖对方定制镜像，另行评估是否值得增加服务 |
| `acc7ebe` | 如本地需要，允许非 mesh 客户端使用代理 | 与 API 隔离成组适配；不直接开放新增 profile 端口，不能放开 9090 |
| `a77b2ba` | OAuth ext-authz path/Set-Cookie/HTTPS redirect 修复 | 本地 oauth2-proxy 已启用且 chartRef 已正确；不能删除本地 infra/staging 的 EnvoyFilter |
| `81c719d` | 显式 ready-marker aggregate gate | 本地 `resources: []` 已成功 kustomize build，属于可选可观测性改进，不是当前必需修复 |
| `e338fa8` | CI diff 大小限制、必要的 custom Secret parser 修复 | 本地已是 flux-local 8.4.0，不降级至 ccsn workaround 的 8.2.0；BGP schema 修复本地不需要 |

已检查本地使用的 **flux-local 8.4.0 源码**：核心 Secret/ConfigMap 识别仍仅按 kind，确实未限制到 `apiVersion: v1`。所以引入 Crossplane 的 `kind: Secret` CR 时仍需 parser 修复，不能仅因本地版本较新就认为此问题已解决。本次迁移已引入这些 CR，并对 CI 和 Nix 镜像锁工具使用的固定 8.4.0 parser 一起修复。

## 可选管理架构迁移：3 个提交

`3410c37` + `5fbb3a6` + `560fcb0`。

这组是 **应用归属的 Logto/Harbor CRD 管理**，并非 HA，也不是独立 PostgreSQL 迁移，因此不应因“不做 HA”一并排除。它包含：

- Crossplane、Logto/Harbor provider、ProxyCache XRD/Composition，以及应用 OIDC client/credential/roles 配置。
- Harbor registry/project/robot 管理从 tofu 转移到 CRD；Logto 配置和各应用身份凭据改由控制器产生。
- Flux identity readiness 与 postBuild/Secret 引用调整，防止应用先于身份凭据就绪。

本地可以保留现有数据库/副本数，只迁移资源管理能力。但它增加控制器与依赖，且必须保留现有资源 ID、凭据、client 和 Harbor registry adapter；不能带入对方 SMTP/GitHub/园区角色/Portainer/品牌配置。按用户后续授权，本次一起引入，使用单独的 Flux 接管阶段。`5fbb3a6` 的 `huawei` adapter 本地 Terraform 已使用；`560fcb0` 的 shared Kubernetes client refresh tokens 仅在采用对应 Application CR 后才有目标资源。

## 版本升级：8 个提交

| Commit | 本地 → ccsn | 处理要求 |
| --- | --- | --- |
| `a7dd6f6` | Flux CLI action 2.9.4 → 2.9.6 | 保持 action SHA 固定 |
| `8c02fde` | Vaultwarden chart 1.12.11 → 1.14.2 | 保留 SQLite、原备份、单副本和本地 SSO consent |
| `6dde79b` | CNPG chart 0.28.2 → 0.29.1 | 保留单实例，核对 CRD 升级并重新 pin digest |
| `d7b8d27` | barman plugin 0.6.0 → 0.8.1 | 核对现有 Logto 备份兼容性，不新增 Vaultwarden PG |
| `60e6e5d` | Flux Operator 0.50.0 → 0.61.0 | 保留本地身份配置，核对 chart 后重新 pin digest |
| `815d3dc` | local-path-provisioner 0.0.36 → 0.0.37 | 保留 local-path-nocow 默认策略，重新 pin digest |
| `7f7ccae` | restarter kubectl 1.36.0 → 1.36.2 | 先核对实际 apiserver 兼容性，不能只按对方集群版本升级 |
| `66eaff7` | cloudflared 2026.8.2 → 2026.10.0 | 保留 tunnel/凭据，重新 pin digest |

除集群版本相关的 kubectl 外，以上升级已适配并保留 digest pin；完整 Helm 渲染验证通过。继续保留本地禁用 automerge 的策略。

## 条件项：3 个提交

- `5a44a76`：Dragonfly CPU 兼容镜像。ccsn 使用其自定义构建，本地已有官方 1.40.1。先确认本地 CPU 是否需要，不能默认改成对方镜像。
- `1850f52`：Cilium native routing 与分配 PodCIDR 对齐。借鉴检查要求，但必须以本地实际 IPAM/PodCIDR 为准；不能直接改为对方 `10.0.0.0/8` / `fd00::/104`。
- `420f6d9`：最终固定的 patched Cloudflare operator 镜像是 `ghcr.io/isning/cloudflare-operator`。有可能适用于本地，但先核对需要的修复和镜像；不照搬 319-core overlay。

## 明确排除的范围

- Logto HA、多实例 PG、新增 Logto Redis/Dragonfly；Vaultwarden 独立 PG 迁移。
- Longhorn、HDD/RWX StorageClass、Harbor/Proxy 双副本与相关节点磁盘设置。
- kube-vip、BGP、319 PodCIDR/负载均衡地址、campus ingress、OpenWrt SmartDNS、园区 DNS scope。
- 外部业务服务、Portainer 接入、DL160/DL380/T410/S5624P/S5100 等设备兼容层、network-admin 角色。
- ccsn 域名、OAuth client IDs、Cloudflare/R2/SMTP/GitHub 凭据及 SOPS recipient；Logto 公司品牌。
- 45 次对方 image lock 刷新：完成本地最终配置后统一重生成自己的锁。
- 7 个实际 merge 提交和已撤销/被替换的临时实现；标题叫 Merge 但只有单父且含实质修改的提交仍按其内容审阅。

## 验证和后续范围

本次核对了上游最终 tree、每个非镜像锁提交的变更路径、关键 patch、本地对应配置、patch 等价性与 merge parents，并验证本地 aggregate gate 的 kustomize 渲染成功。固定 bootstrap 模块 0.7.0 的源码用于核对 revision 类型。以上为盘点阶段的检查。执行阶段已进行 Terraform、Helm 和本地回归验证；没有进行集群部署或运行时接管。

旧清单“只剩 bootstrap 值得引入”的结论已作废。用户后续授权引入全部通用改动及管理迁移，执行结果见文末；业务和集群相关改动继续排除。

参考仓库：[ccsn 最新快照](https://github.com/the-ccsn/k8s-gitops/tree/22ff96a7cdc83baba9ded3c40dcfb2ffea0e4525)、[bootstrap 模块 0.7.0](https://github.com/controlplaneio-fluxcd/terraform-kubernetes-flux-operator-bootstrap/tree/v0.7.0)。

## 数量汇总

| 分类 | 提交数 |
| --- | ---: |
| 推荐 | 7 |
| 适配 | 9 |
| 版本升级 | 8 |
| 可选迁移 | 3 |
| 条件项 | 3 |
| 已有 | 37 |
| 跳过 | 52 |
| 已废弃 | 7 |
| 镜像锁 | 45 |
| 合并 | 7 |
| 合计 | 178 |

## 完整逐提交清单：178 个，无遗漏

按上游拓扑顺序列出，每个提交只归入一个分类。“已有”包括本地适配实现或已被更新版本覆盖，不要求 SHA 相同。

| Commit | 日期 | 分类 | 上游标题 | 本地处理依据 |
| --- | --- | --- | --- | --- |
| `7211a85` | 2026-05-25 | 跳过 | refactor: this is now 319 cluster | 批量改集群名、域名、路由、网络/存储配置，还删除 Astrbot、metapi、Siyuan 等应用；不是通用重构。 |
| `01987fa` | 2026-05-25 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#1) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `899aa94` | 2026-05-25 | 跳过 | fix(build-tofu-runner): push to the-ccsn | 本地应保留 isning 镜像发布目标。 |
| `88f0325` | 2026-05-27 | 跳过 | feat(snc): use kubevip for apiserver ha, cilium bgp for service lb | 319 网络拓扑与 BGP 配置；本地使用 L2 及动态 IPv6 公网池。 |
| `427139c` | 2026-05-27 | 跳过 | feat(snc): rotate secrets in infra | 对方 Secret、tunnel 及关联配置，不能使用本仓库凭据替代方案之外的密文。 |
| `305644a` | 2026-05-27 | 跳过 | fix(snc): disable apps | 对方 bootstrap 状态、issuer/Secret 修改，还移除本地 CA/TLS 资源。 |
| `ec93a5b` | 2026-05-27 | 已有 | chore: sync from cnpg/artifacts@ab1fb64 | `8937f7c`；patch 等价，不再 pick。 |
| `fc1de58` | 2026-05-27 | 已有 | fix(proxy-engine): use full image name for python (#453) | `409f965`；patch 等价。 |
| `da1af7e` | 2026-05-27 | 已有 | fix(proxy-engine): enable downloading external ui for clash API | `ca6b764`、`0b59ceb`、`4c48d9c` 分步覆盖。 |
| `7ed15d9` | 2026-05-27 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#2) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `dbd2012` | 2026-05-27 | 跳过 | fix: update repository URLs to use the-ccsn organization | 会改变 Flux/Terraform 源仓库、runner 镜像等所有权。 |
| `bf318e2` | 2026-05-27 | 跳过 | fix: update apiServerURLs to correct address | 对方集群地址。 |
| `3a6a311` | 2026-05-27 | 适配 | feat(cilium): refactor HelmRelease values into single values yaml | Cilium values 统一，保留本地最终参数；不搬运对方 1850f52 的 PodCIDR/IPAM。 |
| `b9465bd` | 2026-05-27 | 适配 | feat: add new terraform cluster bootstrap flow for flux-operator | Bootstrap 仍保留，但修正数值 revision 类型、写死 API endpoint、版本约束和 Secret YAML 编码；采用本地 shared values。 |
| `dc69414` | 2026-05-27 | 合并 | Merge pull request #3 from the-ccsn/dev | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `e5998a1` | 2026-05-28 | 已有 | Merge pull request #4 from the-ccsn/dev | `87c6222` 适配本地集群；虽然标题是 Merge pull request，实际是单父提交，含实质修改，不能只按标题忽略。 |
| `f00eedc` | 2026-05-28 | 已有 | fix(infra/controllers): make egress to depend on networking | `87c6222` 和当前 infrastructure 的 networking/monitoring 依赖覆盖。 |
| `2e72936` | 2026-05-28 | 已有 | fix(ci): avoid passing large diff through env | `d65b38d`；patch 等价，后续还有 `b0d52b0`。 |
| `9cecce2` | 2026-05-28 | 跳过 | fix(external-dns): update zone-id to correct one (#6) | 对方 Cloudflare zone。 |
| `0b80106` | 2026-05-28 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#7) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `9f02204` | 2026-05-28 | 已有 | fix(istio): add dependencies for istio-cni, istiod, and ztunnel to avoid disconnection of flux controllers which stops bootstrapping | `f5495c1`，已适配现有目录。 |
| `b3874a4` | 2026-05-28 | 已有 | fix(generic-device-plugin): update image reference to include docker.io prefix | `d1e6504`，无需重复。 |
| `5564e9f` | 2026-05-28 | 已有 | fix(egress): seprate egress into configs and controllers | `bf0a010`，无需重复。 |
| `52a0325` | 2026-05-28 | 已有 | fix(image-lock): use canonical_image_name function to handle default Docker registry as final image name | `4cbb194`；patch 等价。 |
| `07e1a2d` | 2026-05-28 | 已有 | fix(proxy-engine): disable invalid monitoring resources | `21b6d2a`；patch 等价。 |
| `2aa321c` | 2026-05-28 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#10) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `286100d` | 2026-05-28 | 已有 | fix(lock): canonicalize image sources | `e97b565`；patch 等价。 |
| `e2580a0` | 2026-05-28 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#12) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `30e4d7e` | 2026-05-28 | 已有 | fix(oauth2-proxy): move it to apps since it requires logto ready to get ready | `1a5d6dc`、后续 `f59d078` 已覆盖本地目录和启用情况。 |
| `6255d5a` | 2026-05-28 | 已有 | !fixup(oauth2-proxy): move it to apps since it requires logto ready to get ready | `1a5d6dc`；JWT 资源后续由 `2e7cbc2` 恢复，不能用旧 patch 覆盖当前认证配置。 |
| `6d5e60d` | 2026-05-28 | 已有 | fix(harbor): move it down to infra/configs since it needs cnpg. | `2c35649`，当前目录已相同。 |
| `7d82d09` | 2026-05-28 | 跳过 | fix: stop use local-path in favor of longhorn instead | 本地已在 `f57172e` 移除 Longhorn，仍用 local-path-nocow；不要清除现有 storageClass。Logto connector PVC 部分若需要，可另行适配。 |
| `afb96a0` | 2026-05-29 | 已有 | feat(lock): support extra image sources via annotations | `80c483f`；README、脚本与 flake 已有这项能力。 |
| `1349315` | 2026-05-28 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#17) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `10f4138` | 2026-05-29 | 跳过 | fix(proxy-engine): use proxied suburls | 只修改对方订阅 Secret；本地已有独立订阅更新。 |
| `5789f70` | 2026-05-29 | 跳过 | fix(319-reroute): 319-reroute -> i319-reroute | 对方服务名、overlay、DNS 标识；本地保留 i-reroute。 |
| `5bfbf1e` | 2026-05-29 | 跳过 | fix(cloudflare-operator): pin tunnel id | 含对方 tunnel ID、密文及 DNS binding；需要时只借鉴引用方式，用自己的 tunnel。 |
| `0f9a55e` | 2026-05-29 | 已有 | fix(istio-base): add extra image annotation for proxyv2 | `47d8e9b`，无需重复。 |
| `78d0c67` | 2026-05-29 | 已有 | fix(tofu-controller): add image-lock annotation for extra images | `e194748`；保留 isning runner 地址和当前 digest。 |
| `e156b2a` | 2026-05-29 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#23) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `e51cb9c` | 2026-05-29 | 已有 | fix(variables): update harbor URL to point to the core service | `30e0e53`；patch 等价。 |
| `af4806a` | 2026-05-29 | 跳过 | chore(apps): enable apps except for oauth2-proxy | 只影响 319 overlay；本地 oauth2-proxy 已有独立启用修复。 |
| `c6f3aad` | 2026-05-29 | 跳过 | fix(logto): rotate cnpg backup credential | 对方 R2 endpoint 与 Secret。 |
| `70f6603` | 2026-05-29 | 跳过 | fix(secret): rotate agekey of secrets | 对方密文与 recipient，不能直接引入。 |
| `84e2ca4` | 2026-05-29 | 已有 | feat(logto): use bucket rentention policy instead of app one to avoid k's of s3 ops | `ee949ea`；patch 等价，后续还有 `f051d10`，不要覆盖后续策略。 |
| `c17b2a3` | 2026-05-30 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#27) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `f474fe4` | 2026-05-30 | 已有 | fix(infra/controllers/monitoring): add missing grafana-operator (#28) | `9ee0ce1`，当前 monitoring 已有。 |
| `03c10c9` | 2026-05-30 | 已有 | fix(logto): enable pre-app job (#29) | `396a7a9` 已包含。 |
| `88907dc` | 2026-05-31 | 已有 | chore(logto): bump version to 0.2.14 | 已由 `396a7a9` 的 0.3.1 覆盖，不能降级。 |
| `fb8f31a` | 2026-05-31 | 已有 | fix(flux): pin version and add image-lock extra images annotation | `c43a83a`；当前 Flux 及 annotation 已更新，无需覆盖。 |
| `aa6bdcc` | 2026-05-31 | 跳过 | fix(snc): enroll oauth credentials | 对方 client IDs、issuer 及 Secret。 |
| `1e1042d` | 2026-05-31 | 跳过 | feat(logto): HA logto | 用户确认不做 HA，保留现有部署规模；不引入这组副本和 Redis 依赖。 |
| `73910ab` | 2026-05-31 | 已有 | fix(logto): 0.3.1 for chart fix | `396a7a9` 已包含，当前还锁定了 digest。 |
| `81d8ab3` | 2026-05-31 | 跳过 | fix(logto): add missing reference to redis resources | 依赖已排除的 Logto HA 方案，无需引入。 |
| `79ca90e` | 2026-05-31 | 跳过 | fix(logto): uri encode pasword in redis_url | 修改对方加密 Secret，且仅服务于已排除的 Logto Redis 方案。 |
| `ad9ff6f` | 2026-05-31 | 跳过 | fix(logto): disable redis network policy since it conflicts with istio HBONE | 当前没有这套 Logto Redis 资源，无需引入 NetworkPolicy 和 chartRef 修复。 |
| `aec21f8` | 2026-06-01 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#34) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `75cb78f` | 2026-06-01 | 跳过 | refactor(storage): split longhorn StorageClass into longhorn (no backup) and longhorn-backup (default, with backup) | 本地没有 Longhorn；还改变默认存储及多个应用的 storageClass，不能作为普通修复引入。 |
| `34f0c6e` | 2026-06-01 | 跳过 | feat(vaultwarden): migrate from sqlite to external PG with barman-cloud backup | 用户确认不改独立 PostgreSQL；保留现有 SQLite 与备份方案。 |
| `bd093bb` | 2026-06-01 | 跳过 | fix(longhorn): quote full-backup-interval as string in RecurringJob | 仅修复上一项新增的 Longhorn 资源，本地不存在。 |
| `65791a0` | 2026-06-02 | 跳过 | fix(longhorn): use correct recurringJobSelector format in StorageClass | 同上，非独立通用修复。 |
| `214b1c1` | 2026-06-02 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#38) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `88b5da0` | 2026-06-02 | 跳过 | fix(longhorn): use BackupTarget CR for R2 instead of defaultBackupStore (#39) | 同上，绑定对方 R2/备份方案。 |
| `66f38c2` | 2026-06-03 | 跳过 | fix(oauth2-proxy, snc): update expected audience of authn | 对方 Logto client ID / audience，保留本地身份配置。 |
| `ee7f05f` | 2026-06-03 | 已有 | feat(proxy-engine): add subscription-source grouping to selectors and validate outbound retry | 订阅来源分组已由本地 a4735e3 / 369b0b2 引入；后续 3400053 的缓存与隔离逻辑另评估。 |
| `111f131` | 2026-06-03 | 已有 | refactor(proxy-engine): make high-rate groups selector with nested urltest | 订阅来源分组已由本地 a4735e3 / 369b0b2 引入；后续 3400053 的缓存与隔离逻辑另评估。 |
| `5433e8f` | 2026-06-03 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#41) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `0e3ce80` | 2026-06-06 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#42) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `b53676e` | 2026-06-16 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#43) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `aae5a8f` | 2026-06-17 | 已有 | fix: restore oauth2-gateway-jwt RequestAuthentication for gateways | 本地 2e7cbc2 已恢复 gateway JWT，保留本地 issuer/audience。 |
| `ce151ac` | 2026-06-17 | 已有 | fix(istio): repalce helm chart reference with nju mirror one | 本地 3961479 已切 Istio 南京镜像，当前对应文件相同。 |
| `ed9576f` | 2026-06-17 | 已有 | feat: add dragonfly-operator and replace Harbor Redis with Dragonfly | 本地 daf2f8b 已将 Harbor Redis 换成单实例 Dragonfly；后续 CPU 镜像条件项另评估。 |
| `55f46a5` | 2026-06-17 | 跳过 | feat(logto): replace Bitnami Redis with Dragonfly | 只服务于未采用的 Logto Redis/Dragonfly 多副本方案；本地 Logto 不新增缓存服务。 |
| `48a7af4` | 2026-06-17 | 已有 | fix: add istio.io/dataplane-mode: ambient label to flux-system namespace | 本地 FluxInstance 的 Namespace patch 已设置 ambient 标签；不必新增重复 Namespace 定义。 |
| `dfd3a1d` | 2026-06-17 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#44) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `000543b` | 2026-06-19 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#45) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `d58d2a9` | 2026-06-23 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#46) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `be38eb3` | 2026-06-30 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#47) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `bee5424` | 2026-07-03 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#48) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `2ef8f43` | 2026-07-05 | 已有 | fix: add retentionPolicy(14d) and instanceSidecarConfiguration to logto and vaultwarden objectstore | 本地 f051d10 已覆盖 Logto 的 retention 和 sidecar 配置；Vaultwarden PG 部分按用户要求排除。 |
| `925d516` | 2026-07-07 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#49) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `67a9d7d` | 2026-07-08 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#50) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `dc51c12` | 2026-07-09 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#51) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `2efe228` | 2026-07-10 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#52) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `cf7f613` | 2026-07-23 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#53) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `a1321ae` | 2026-07-26 | 跳过 | fix(kiali): use canonical public hostname | 对方域名、园区 ingress / split DNS / BGP 标识，不迁移本地 L2 与动态 IPv6 拓扑。 |
| `fff2027` | 2026-07-26 | 跳过 | fix(i319): align reroute domains | 对方域名、园区 ingress / split DNS / BGP 标识，不迁移本地 L2 与动态 IPv6 拓扑。 |
| `cefdf20` | 2026-07-26 | 适配 | feat(egress): add dual-stack network profiles (#55) | 拆取代理 public IPv4/IPv6 profile；排除 campus profiles、对方网络地址与新增不必要监听端口。 |
| `bc2f547` | 2026-08-01 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#56) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `cf2e2bd` | 2026-08-04 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#57) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `140c649` | 2026-08-09 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#58) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `bcd60e0` | 2026-08-10 | 已有 | chore(vaultwarden): Update Vaultwarden Helm chart tag to `1.12.11` | 本地 a7b0836 已升级至 1.12.11；后续 1.14.2 单列升级。 |
| `c85fd44` | 2026-08-11 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#64) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `49e3a92` | 2026-08-13 | 已有 | chore(deps): pin dependencies (#59) | 本地 4df0d98 已做依赖 pin，cloudflared 后续已更新；对方 kube-vip 不引入。 |
| `07fa69e` | 2026-08-13 | 已有 | chore(deps): update ghcr.io/dragonflydb/dragonfly docker tag to v1.40.1 (#74) | 本地 425ddde 已升级官方 Dragonfly 至 1.40.1。 |
| `ed669d9` | 2026-08-13 | 已有 | chore(deps): update cloudflare/cloudflared docker tag to v2026.7.3 (#69) | 本地 62693f6 已引入，当前 cloudflared 已为 2026.8.2，不降级。 |
| `2c37d22` | 2026-08-14 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#75) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `d3bd4b4` | 2026-08-15 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#76) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `f021944` | 2026-08-18 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#77) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `9c0b839` | 2026-08-19 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#78) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `ae9dcc0` | 2026-08-21 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#79) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `d06e8ca` | 2026-08-23 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#80) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `4b3d0e7` | 2026-08-27 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#81) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `76a206a` | 2026-09-02 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#82) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `fcd4051` | 2026-09-04 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#83) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `6799de2` | 2026-09-18 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#84) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `fd6aaf9` | 2026-09-20 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#85) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `1368bee` | 2026-09-21 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#86) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `f702480` | 2026-09-23 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#87) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `5dd4bba` | 2026-09-24 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#88) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `18fabdd` | 2026-09-25 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#89) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `3942a6b` | 2026-09-30 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#90) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `2da3dbe` | 2026-10-03 | 跳过 | feat(storage): add two-replica Longhorn HDD storage class (#91) | 对方 Longhorn 磁盘节点、RWX 存储或多副本配置；本地不引入 Longhorn、不做 HA。 |
| `5a44a76` | 2026-10-03 | 条件项 | fix(dragonfly): deploy the CPU-compatible image pinned by digest (#92) | CPU 兼容 Dragonfly 镜像是对方自定义构建；本地 Harbor 已用官方单实例，先确认本地 CPU 是否需要此变体，不替换成对方镜像作为默认。 |
| `1850f52` | 2026-10-03 | 条件项 | fix(cilium): align native routing with allocated Pod CIDRs (#93) | 先确认本地实际 Cilium PodCIDR 分配；只借鉴 routing CIDR 与 IPAM 一致性要求，不能直接切到对方 10.0.0.0/8、fd00::/104。 |
| `e0a33a5` | 2026-10-03 | 跳过 | fix(logto): allow ambient transport to Dragonfly (#94) | 只服务于未采用的 Logto Redis/Dragonfly 多副本方案；本地 Logto 不新增缓存服务。 |
| `4175695` | 2026-10-03 | 跳过 | fix(logto): label Dragonfly pods for environment policy (#95) | 只服务于未采用的 Logto Redis/Dragonfly 多副本方案；本地 Logto 不新增缓存服务。 |
| `121f771` | 2026-10-04 | 推荐 | fix(istio): retry ambient detection and roll CNI pods | Istio ambient detection retry；pod annotation 改本地标识，保留当前 CNI chart 与调优。 |
| `ea91da7` | 2026-10-04 | 推荐 | fix(flux): allow gateway HBONE access to the web UI | 补 Flux Web 的 HBONE 15008 入站策略，适配到本地现有 flux-operator HelmRelease，保留 OAuth Secret 与目录。 |
| `b06958a` | 2026-10-04 | 推荐 | fix(monitoring): restore verified node metrics and bound labels | 节点指标 HTTPS、ServiceAccount token/CA 和有限标签集合；去掉 vmagent 自定义 CA 仅在确认本地无需挂载时采用。 |
| `2b4af4c` | 2026-10-04 | 跳过 | fix(vaultwarden): use RWX storage for rolling updates | 对方 Longhorn 磁盘节点、RWX 存储或多副本配置；本地不引入 Longhorn、不做 HA。 |
| `3400053` | 2026-10-04 | 适配 | fix(egress): support RWX replicas and native Web UI with mesh authorization | 只取原子缓存写入、runtime config 隔离、API 访问保护与可选 Web UI；排除两副本、Longhorn/RWX，native UI 使用对方定制镜像须另评估。 |
| `ec14602` | 2026-10-04 | 跳过 | fix(harbor): use native RWX storage and replica settings | 对方 Longhorn 磁盘节点、RWX 存储或多副本配置；本地不引入 Longhorn、不做 HA。 |
| `9bcc16a` | 2026-10-04 | 合并 | Merge pull request #100 from the-ccsn/fix/cluster-recovery-kiss | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `b1f40c9` | 2026-10-04 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#101) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `a77b2ba` | 2026-10-04 | 适配 | fix(auth): enable OAuth2 Proxy and restore gateway login redirects (#102) | oauth2-proxy 已在本地启用，但 ext-authz pathPrefix、Set-Cookie 与 HTTPS redirect 部分仍不同；不能删除本地 infra/staging 的过滤器。 |
| `ea9a1b2` | 2026-10-04 | 推荐 | fix(egress): preserve Proxy workload identity in CONNECT endpoints (#103) | CONNECT ServiceEntry 改为 workloadSelector，保留 proxy-engine 工作负载身份；核对本地 app selector/端口，独立于 HA。 |
| `8c02fde` | 2026-10-04 | 版本升级 | chore(deps): update ghcr.io/helmforgedev/helm/vaultwarden docker tag to v1.14.2 (#104) | Vaultwarden chart 1.12.11 → 1.14.2；保持 SQLite、现有备份、单副本和 SSO consent，不引入对方 PG/RWX。 |
| `acc7ebe` | 2026-10-04 | 适配 | fix(proxy): accept non-mesh clients on proxy listeners (#105) | 仅在实际需要非 mesh 代理客户端时调整 PeerAuthentication/AuthorizationPolicy；保留 9090 API 隔离，不批量开放新增端口。 |
| `aa5fb22` | 2026-10-05 | 镜像锁 | chore(lock): update image lock for cluster kubevirt-cluster-319 (#106) | 对方 319 集群生成产物不搬运；最终配置确定后重生成本地锁。 |
| `5665c6c` | 2026-10-06 | 已有 | fix(vaultwarden): request consent for SSO refresh tokens (#107) | 本地最新 main 的 b1cdec8 已加入 SSO consent，当前配置已覆盖。 |
| `4aba38d` | 2026-10-06 | 跳过 | fix(i319): require dual-stack campus ingress | 对方域名、园区 ingress / split DNS / BGP 标识，不迁移本地 L2 与动态 IPv6 拓扑。 |
| `ccd6593` | 2026-10-06 | 跳过 | feat(gateway): migrate external services from Caddy | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `3410c37` | 2026-10-06 | 可选迁移 | feat: manage Logto and Harbor with application-owned CRDs | 应用归属 Logto/Harbor CRD + Crossplane 是可移植管理能力、与 HA 无关；需独立迁移身份/Harbor 资源与凭据，不直接应用整份大提交。 |
| `dba5d9d` | 2026-10-06 | 适配 | docs: define Kubernetes bootstrap and NixOS handoff | 仅借鉴 NixOS/Kubernetes 启动边界、检查和恢复流程；对方文档仍含 string revision=main 与实际模块 number 要求冲突，需修正。 |
| `81c719d` | 2026-10-06 | 适配 | fix: make infrastructure controller aggregate renderable | ready-marker 可作为显式 aggregate gate；本地 resources: [] 已成功 kustomize build，不视为当前渲染故障。 |
| `e338fa8` | 2026-10-06 | 适配 | fix(ci): validate current Cilium and custom Secret resources | 拆取 CI 大 diff 截断和必要 parser 修复；不降级本地 flux-local 8.4.0 至 8.2.0，也不照搬仅服务 BGP 的 schema 下载。 |
| `a7dd6f6` | 2026-10-06 | 版本升级 | chore(deps): update fluxcd/flux2 action to v2.9.6 (#70) | Flux CLI action 2.9.4 → 2.9.6；按固定 action SHA 更新。 |
| `5fbb3a6` | 2026-10-06 | 可选迁移 | fix(harbor): preserve existing Istio registry adapter | 只在采用 3410c37 后引入；本地现有 tofu Harbor registry adapter 已是 huawei。 |
| `8aa040f` | 2026-10-06 | 跳过 | fix(gateway): adapt legacy external device HTTP and TLS | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `b235336` | 2026-10-06 | 跳过 | fix(cilium): restore BGP peering and bootstrap gateway labels | 对方域名、园区 ingress / split DNS / BGP 标识，不迁移本地 L2 与动态 IPv6 拓扑。 |
| `f3c3705` | 2026-10-06 | 合并 | Merge pull request #112 from the-ccsn/fix/external-services-bgp-compat | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `12b7679` | 2026-10-06 | 跳过 | fix(external-dns): use supported exclusion selector | 对方域名、园区 ingress / split DNS / BGP 标识，不迁移本地 L2 与动态 IPv6 拓扑。 |
| `1c755e3` | 2026-10-06 | 合并 | Merge pull request #113 from the-ccsn/fix/external-dns-annotation-selector | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `3feb915` | 2026-10-06 | 跳过 | fix(gateway): preserve the adopted S5624P adapter selector | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `b484157` | 2026-10-06 | 合并 | Merge pull request #114 from the-ccsn/fix/s5624p-deployment-adoption | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `1174fb5` | 2026-10-06 | 跳过 | fix(gateway): strip Cloudflare identity headers before legacy switch | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `ea93479` | 2026-10-06 | 合并 | Merge pull request #115 from the-ccsn/fix/s5624p-cloudflare-headers | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `6dde79b` | 2026-10-06 | 版本升级 | chore(deps): update ghcr.io/cloudnative-pg/charts/cloudnative-pg docker tag to v0.29.1 (#71) | CNPG chart 0.28.2 → 0.29.1；保留单实例与 digest pin，核对 CRD 升级。 |
| `d7b8d27` | 2026-10-06 | 版本升级 | chore(deps): update ghcr.io/cloudnative-pg/charts/plugin-barman-cloud docker tag to v0.8.1 (#72) | barman plugin chart 0.6.0 → 0.8.1；保留 Logto 现有备份配置并核对兼容性，不新增 Vaultwarden PG。 |
| `86eb8c7` | 2026-10-06 | 跳过 | feat(network): require Logto network admin through OAuth2 gateway | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `0f973e0` | 2026-10-06 | 合并 | Merge pull request #118 from the-ccsn/feat/network-device-sso | 只作为历史容器，按实际子提交与最终状态选择，不单独 cherry-pick。 |
| `60e6e5d` | 2026-10-06 | 版本升级 | chore(deps): update ghcr.io/controlplaneio-fluxcd/charts/flux-operator docker tag to v0.61.0 (#73) | Flux Operator 0.50.0 → 0.61.0；保留本地 OAuth/FluxInstance 配置，升级时重锁 chart digest。 |
| `815d3dc` | 2026-10-07 | 版本升级 | chore(deps): update ghcr.io/rancher/local-path-provisioner/charts/local-path-provisioner docker tag to v0.0.37 (#119) | local-path-provisioner 0.0.36 → 0.0.37；保持 local-path-nocow 默认存储与当前参数，重锁 digest。 |
| `7f7ccae` | 2026-10-07 | 版本升级 | chore(deps): update rancher/kubectl docker tag to v1.36.2 (#120) | proxy restarter kubectl 1.36.0 → 1.36.2；先核对实际 apiserver 版本兼容，再更新 digest。 |
| `66eaff7` | 2026-10-07 | 版本升级 | chore(deps): update cloudflare/cloudflared docker tag to v2026.10.0 (#121) | cloudflared 2026.8.2 → 2026.10.0；保持本地 tunnel 与凭据，并重新 pin digest。 |
| `8c6ce62` | 2026-10-07 | 已废弃 | fix(snc): use patched Cloudflare operator image | 初始 Cloudflare operator 镜像选择已由 420f6d9 改为固定 tested build。 |
| `420f6d9` | 2026-10-07 | 条件项 | fix(snc): pin tested Cloudflare operator build | 最终 patched Cloudflare operator 是 ghcr.io/isning/cloudflare-operator 的固定 build；按本地实际所需修复验证，可提取镜像 override，不引入 319-core overlay。 |
| `560fcb0` | 2026-10-07 | 可选迁移 | fix(oidc): issue refresh tokens for shared Kubernetes client | 只在采用 Logto Application CR 管理后迁移 shared Kubernetes client refresh-token 设置；保留本地 client 身份和角色。 |
| `48350fd` | 2026-10-07 | 推荐 | fix(headlamp): update plugins and track image volumes with Renovate | Headlamp plugin 升级、cert-manager installer 与 Renovate image-volume 跟踪；保留本地 0.44.0 chart、OIDC 和禁用 automerge 策略。 |
| `d922ad4` | 2026-10-08 | 已废弃 | fix(headlamp): pull plugin manager runtime through Google mirror | Google mirror runtime 切换被 1d6f915 恢复；最终使用 node:24-alpine，直接取最终状态。 |
| `1d6f915` | 2026-10-08 | 已废弃 | fix(headlamp): restore Docker Hub runtime image source | Google mirror runtime 切换被 1d6f915 恢复；最终使用 node:24-alpine，直接取最终状态。 |
| `b7c46d3` | 2026-10-08 | 推荐 | fix(headlamp): route plugin downloads through cluster egress proxy | Headlamp 插件下载走现有集群代理；需核对 Node runtime 的 env proxy 支持并验证下载。 |
| `2ad9313` | 2026-10-08 | 推荐 | fix(headlamp): isolate image plugins from installer cleanup | OCI 插件移至 static-plugins，避免 installer 清理挂载目录；与 48350fd 成组。 |
| `bc0235b` | 2026-10-08 | 跳过 | fix(s5624p): bound legacy switch request headers | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `508361d` | 2026-10-08 | 跳过 | fix(auth): retain campus login origin through forwarded host | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `9533ce1` | 2026-10-08 | 跳过 | fix(s5624p): preserve legacy HTTP header case for login | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `f69ca0d` | 2026-10-08 | 跳过 | fix(s5100): normalize authenticated login requests for legacy web server | 对方园区设备/外部业务服务、旧交换机 HTTP/TLS 适配和网络管理员角色；本地没有这些资源。 |
| `b95722e` | 2026-10-08 | 跳过 | style(logto): customize account center and sign-in colors | 对方 Logto 品牌颜色、公司 logo 与响应式样式，不是本地通用配置。 |
| `e9568bf` | 2026-10-08 | 已废弃 | feat(logto): add combined SNC and CCSN branding for both themes | 已被后续提交完整撤销，最新 tree 没有这项修改；无需应用再 revert。 |
| `4326acf` | 2026-10-08 | 已废弃 | Revert "feat(logto): add combined SNC and CCSN branding for both themes" | 已被后续提交完整撤销，最新 tree 没有这项修改；无需应用再 revert。 |
| `7a15c3e` | 2026-10-08 | 跳过 | style(logto): use hosted company logos and responsive sizing | 对方 Logto 品牌颜色、公司 logo 与响应式样式，不是本地通用配置。 |
| `a638de6` | 2026-10-08 | 跳过 | style(logto): allow enlarged branding to fit short mobile screens | 对方 Logto 品牌颜色、公司 logo 与响应式样式，不是本地通用配置。 |
| `dc03850` | 2026-10-08 | 跳过 | feat(dns): expose Gateway split DNS for OpenWrt SmartDNS | 对方 OpenWrt SmartDNS、ccsn.dev split DNS 和 DNS LB 地址；还含两副本，不按原样引入。 |
| `4e35001` | 2026-10-08 | 跳过 | fix(dns): allow time for the initial Codeberg image pull | 对方 OpenWrt SmartDNS、ccsn.dev split DNS 和 DNS LB 地址；还含两副本，不按原样引入。 |
| `401c66a` | 2026-10-08 | 跳过 | fix(dns): match deployment progress deadline to pull timeout | 对方 OpenWrt SmartDNS、ccsn.dev split DNS 和 DNS LB 地址；还含两副本，不按原样引入。 |
| `05ab252` | 2026-10-08 | 已废弃 | fix(dns): bypass OpenWrt UDP interception for public fallback | 已被后续提交完整撤销，最新 tree 没有这项修改；无需应用再 revert。 |
| `22ff96a` | 2026-10-08 | 已废弃 | Revert "fix(dns): bypass OpenWrt UDP interception for public fallback" | 已被后续提交完整撤销，最新 tree 没有这项修改；无需应用再 revert。 |

## 本次实现状态

- 已 cherry-pick `121f771`、`ea9a1b2`、`b06958a`，其余通用改动按本地最终配置适配；不照搬历史 image-lock。
- 已引入 Cilium shared values/bootstrap、Flux HBONE policy、OAuth 修复、Headlamp plugins、单实例代理及原生 UI、CI parser/diff 修复和通用依赖升级。保留本地 PG 规模、Vaultwarden SQLite、动态 IPv6、L2、本地 RWO 存储。
- 已引入 Crossplane 和应用归属的身份/Harbor CR 管理。管理配置与应用身份接管暂时暂停，待填写 SOPS 管理凭据、现有 Harbor IDs、Flux client ID 和 Logto secret names 后分阶段启用。详情见 `infra/pre-controllers/base/crossplane/README.md`。
- 原 Terraform/消费者 Secret 在接管验证完成前保留。未导入业务角色、园区网络、HA、多副本/RWX、对方域名或数据库迁移。

前面的历史分类是重新盘点依据；“可选/条件/待评估”的通用部分已按本节落实，业务和集群相关部分继续排除。

### 执行验证

- Terraform init/fmt/validate 通过。
- 112 个 Kustomize 目录构建通过，423 次核心 Kubernetes 和 123 次 Flux schema 校验通过（重复包含的资源按各目录计数；其他 CRD 按现有策略跳过）。21 个新增管理资源使用 provider/XRD schema 单独验证通过。
- 完整 flux-local Helm 测试 37/37 通过；动态 IPv6 18 项和代理/镜像锁回归 8 项通过。
- 新增核心 Secret 均 SOPS 加密，用户填写的 Logto M2M 凭据通过 MAC/解密回读校验。
- 公网管理 API 只读查询返回 HTTP 403，现有资源 ID 未核实；接管层保持暂停。
- 镜像锁生成支持 `--reuse-locked-images`：保留未变更镜像/tag/platform 的现有 immutable digest/archive hash，明确改变的 manifest digest 不复用。新增/升级的镜像仍正常解析和计算 archive hash。

- 镜像锁已由只读 CI 生成并验证：69 个镜像条目，所有 digest/archive hash 格式校验通过；Crossplane hash 与本地同 digest 的 Docker Hub 独立计算结果一致。生成工作流及全部检查通过：[CI run](https://github.com/isning/k8s-gitops/actions/runs/37763751416)。
