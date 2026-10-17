# 安全归约报告格式

## 总则

完整审查必须保存为独立的 UTF-8 Markdown 文件。报告采用固定章节，并包含一个
唯一权威的 YAML 数据块。图、表格、问题清单和人工审核队列必须从该 YAML 数据派生，
不得引入 YAML 中不存在的事实或状态。

创建报告时复制 `../assets/security-review-report-template.md`，不得在模板文件中直接
填写某次审查结果。

使用以下固定章节顺序：

1. `# 密码实现安全归约报告`
2. `## 审查摘要`
3. `## 范围、威胁模型与排除项`
4. `## 权威依据与证据覆盖`
5. `## 规范化报告数据`
6. `## 安全归约图`
7. `## 节点评估`
8. `## 明确问题`
9. `## 人工审核队列`
10. `## Formal Verification 交接`
11. `## 验证活动`
12. `## 覆盖范围与残余不确定性`

没有内容的派生章节也必须保留，并明确写“无”。

## 权威 YAML 数据块

`## 规范化报告数据` 下必须恰好包含一个标记为 `yaml` 的代码块。顶层结构如下：

```yaml
schema_version: "0.1-draft"
review:
  id: "CR-YYYYMMDD-NNN"
  title: "..."
  created_at: "YYYY-MM-DD"
  reviewer: "..."
  target_revision: "commit、release、文件摘要或其他稳定标识"
  scope_summary: "..."
  overall_status: PASS | FAIL | NEEDS_HUMAN_REVIEW

roots: [SR-001]

sources:
  - id: SRC-001
    kind: standard | paper | repository | test_vector | advisory | tool_output | other
    title: "..."
    version: "..."
    locator: "URL、文件路径、章节、提交或命令"
    status: authoritative | supporting | provisional

evidence:
  - id: EV-001
    kind: code_inspection | specification_analysis | test | vector | static_analysis | proof | external_attestation | other
    source_refs: [SRC-001]
    target: "文件、函数、协议步骤或节点"
    method: "..."
    result: "..."
    limitations: "..."

nodes:
  - id: SR-001
    kind: security_requirement
    statement: "可证伪的安全陈述"
    source_refs: [SRC-001]
    decomposition:
      operator: AND
      rationale: "为什么这些子节点足以支撑本节点"
      children:
        - node_id: SP-001
          relation: REFINES
    stop_reason: null
    status: NEEDS_HUMAN_REVIEW
    status_origin: DIRECT | PROPAGATED
    status_rationale: "..."
    evidence_refs: []
    acceptance_check: "..."
    required_outcome: "该节点最终必须满足的结果"
    human_review: null
    formalization: null

findings: []
human_review_queue: []
formalization_targets: []
validation_activities: []
coverage:
  reviewed: []
  excluded: []
  residual_uncertainty: []
```

允许增加向后兼容的描述性字段，但不得改变既有字段含义或使用第四种状态。

## 节点字段约束

### 通用约束

- `id` 必须唯一、稳定并使用类型前缀，例如 `SR-001`、`PO-002`、`IO-003`。
- `statement` 必须是可判断真假的陈述，不能只是主题、文件名或动作。
- `source_refs`、`evidence_refs` 中的 ID 必须存在。
- `status` 只能是 `PASS`、`FAIL` 或 `NEEDS_HUMAN_REVIEW`。
- `status_origin` 只能是 `DIRECT` 或 `PROPAGATED`。叶节点必须是 `DIRECT`；非叶节点
  若完全由子节点状态计算则使用 `PROPAGATED`，若存在该节点自身的直接反例或未决
  判断则使用 `DIRECT`。
- `status_rationale` 必须解释证据和传播规则如何产生该状态。
- `acceptance_check` 必须描述复审时如何观察节点已经满足。
- `required_outcome` 描述需要成为真的结果，不得包含可直接应用的修复代码。

### 非叶节点

- `decomposition.operator` 必须是 `AND` 或 `OR`；
- `children` 不得为空；
- `decomposition.rationale` 不得为空；
- `stop_reason` 必须为 `null`。

### 叶节点

- `decomposition.operator` 必须是 `LEAF`；
- `children` 必须为空；
- `stop_reason` 必须是 `machine_checkable`、`human_judgment`、
  `external_assumption`、`formalization_boundary` 或 `counterexample`。

### 人工审核节点

状态为 `NEEDS_HUMAN_REVIEW` 且 `status_origin` 为 `DIRECT` 时，`human_review`
必须包含：

```yaml
human_review:
  question: "一个范围有限、可以回答的问题"
  expertise: "所需专家能力"
  required_evidence: ["作出判断所需的材料或实验"]
  impact_if_unresolved: "未解决时影响哪些上层结论"
```

其他状态以及仅由传播得到未决状态的节点，其 `human_review` 必须为 `null`。
传播得到未决状态的节点必须在 `status_rationale` 中列出阻塞它的直接子节点。

### 形式化验证候选节点

节点适合进入后续形式化验证时，`formalization` 必须包含：

```yaml
formalization:
  proposition: "待证明命题"
  preconditions: ["前置条件"]
  state_model: "状态、参与方和转换"
  inputs: ["公开输入、秘密输入和攻击者输入"]
  invariants: ["需要保持的不变量"]
  expected_result: "证明完成后应得到的结论"
  model_boundary: ["模型明确不覆盖的内容"]
  code_mapping: ["文件、函数、行号或生成代码映射"]
```

不适合形式化的节点使用 `formalization: null`。

## 问题条目

每个直接判定为 `FAIL` 的节点必须被至少一个 finding 引用。仅由状态传播得到
`FAIL` 的祖先节点不重复生成 finding。finding 使用：

```yaml
- id: F-001
  title: "简洁标题"
  severity: Critical | High | Medium | Low
  review_area: Algorithm and Protocol Security | Implementation Correctness | Usage and Integration Security
  confidence: High | Medium | Low
  node_refs: [IO-003]
  claim_or_location: "..."
  preconditions: "..."
  evidence_refs: [EV-004]
  impact: "..."
  required_outcome: "..."
  acceptance_check: "..."
  uncertainty: "..."
```

finding 不是独立事实来源；状态、证据和整改要求必须与所引用节点一致。

## 人工审核队列

每个直接判定为 `NEEDS_HUMAN_REVIEW` 的节点必须恰好出现一次。仅由状态传播得到
未决状态的祖先节点不进入队列：

```yaml
- node_id: AS-002
  priority: blocking | high | normal
  question: "..."
  expertise: "..."
  required_evidence: ["..."]
  blocked_roots: [SR-001]
```

`question`、`expertise` 和 `required_evidence` 必须与节点中的 `human_review` 一致。

## Formal Verification 队列

具有非空 `formalization` 字段的节点必须在 `formalization_targets` 中恰好出现一次：

```yaml
- node_id: FT-001
  priority: blocking | high | normal
  depends_on: [AS-001]
  blocked_by: [HR-001]
```

详细命题只保存在节点的 `formalization` 字段中，队列只表达顺序和依赖。

## 安全归约图

该章节必须包含 Mermaid `flowchart TD`。要求：

- 每个 YAML 节点在图中恰好出现一次；
- 标签包含节点 ID、简短陈述和状态；
- `PASS` 使用绿色，`FAIL` 使用红色，`NEEDS_HUMAN_REVIEW` 使用黄色；
- 每条父子关系均出现，并标注 `relation`；
- Mermaid 只是 YAML 的可视化；冲突时以 YAML 为准，并视为报告校验失败。

## 整体状态

`review.overall_status` 由所有根节点计算：

- 任一根节点 `FAIL`，整体为 `FAIL`；
- 所有根节点 `PASS`，整体为 `PASS`；
- 其他情况为 `NEEDS_HUMAN_REVIEW`。

不得用 findings 数量、最高严重性或主观评分替代此规则。

## 交付前一致性检查

交付前必须确认：

- 图为有向无环图；
- 至少有一个根节点；
- 每个非根节点都可从根抵达；
- 所有引用均存在，无孤立证据、问题或形式化目标；
- 非叶节点和叶节点满足各自字段约束；
- 状态传播与安全归约方法一致；
- 每个直接失败节点关联 finding，传播失败节点不产生重复 finding；
- 每个直接未决节点进入人工审核队列，传播未决节点不产生重复任务；
- 每个派生 Markdown 章节与 YAML 数据一致；
- 范围和排除项明确声明源码级与硬件级侧信道覆盖边界。
