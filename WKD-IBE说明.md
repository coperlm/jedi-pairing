# WKD-IBE 完整加密/解密说明

## 什么是 WKD-IBE？

WKD-IBE (Wildcarded Key-Derivation Identity-Based Encryption) 是一种支持通配符和密钥派生的基于身份的加密方案。它允许根据属性列表进行灵活的访问控制。

## 为什么需要 cryptutils 包？

WKD-IBE 采用**混合加密方案**：

### 传统方式 vs WKD-IBE 方式

```
传统公钥加密：
用户数据 --> 直接用公钥加密 --> 密文

WKD-IBE混合加密：
随机群元素 --> WKD-IBE加密 --> 群元素密文
     ↓ 哈希
  对称密钥 --> AES加密用户数据 --> 数据密文

最终密文 = 群元素密文 + 数据密文
```

### 为什么这样设计？

1. **效率考虑**：公钥加密很慢，只适合加密小量数据（如密钥）
2. **安全性**：对称加密很快，适合加密大量数据
3. **灵活性**：通过群元素可以实现复杂的访问控制策略

## 完整的加密/解密流程

### 加密过程：

```go
// 1. 生成随机群元素
randomMessage := new(cryptutils.Encryptable).Random()

// 2. 用WKD-IBE加密群元素
ciphertext := wkdibe.Encrypt(randomMessage, params, attributes)

// 3. 将群元素哈希为对称密钥
symmetricKey := make([]byte, 32)
randomMessage.HashToSymmetricKey(symmetricKey)

// 4. 用对称密钥加密实际数据
encryptedData := encryptWithAES(userData, symmetricKey)

// 最终密文包含：ciphertext + encryptedData
```

### 解密过程：

```go
// 1. 用WKD-IBE解密群元素
decryptedMessage := wkdibe.Decrypt(ciphertext, secretKey)

// 2. 将群元素哈希为对称密钥
symmetricKey := make([]byte, 32)
decryptedMessage.HashToSymmetricKey(symmetricKey)

// 3. 用对称密钥解密实际数据
userData := decryptWithAES(encryptedData, symmetricKey)
```

## 属性访问控制

### 属性列表示例：

```go
// 完整属性：部门=工程 AND 级别=高级
attributes := wkdibe.AttributeList{
    0: big.NewInt(1), // 部门=工程
    1: big.NewInt(2), // 级别=高级
}

// 部分属性：只有部门=工程
partialAttributes := wkdibe.AttributeList{
    0: big.NewInt(1), // 部门=工程
    // 级别未指定
}
```

### 访问控制规则：

- 拥有**更多属性**的密钥可以解密**要求较少属性**的密文
- 拥有**较少属性**的密钥无法解密**要求更多属性**的密文
- 支持通配符匹配和层次化访问控制

## 实际应用场景

### 1. 企业文档管理
```
属性 0: 部门 (1=工程, 2=市场, 3=财务)
属性 1: 级别 (1=员工, 2=主管, 3=经理)
属性 2: 项目 (1=项目A, 2=项目B, 3=项目C)

加密策略：部门=工程 AND 级别>=主管 AND 项目=项目A
```

### 2. 医疗记录系统
```
属性 0: 医院 (1=医院A, 2=医院B)
属性 1: 科室 (1=内科, 2=外科, 3=儿科)
属性 2: 权限级别 (1=护士, 2=医生, 3=主任)

加密策略：医院=医院A AND 科室=内科 AND 权限级别>=医生
```

### 3. 云存储访问控制
```
属性 0: 组织 (1=公司A, 2=公司B)
属性 1: 部门 (1=技术, 2=销售, 3=管理)
属性 2: 安全级别 (1=公开, 2=内部, 3=机密, 4=绝密)

加密策略：组织=公司A AND 安全级别<=内部
```

## 优势

1. **细粒度访问控制**：支持复杂的属性组合
2. **高效性能**：混合加密兼顾安全性和效率
3. **灵活性**：支持通配符和层次化策略
4. **可扩展性**：可以动态添加新的属性类型

## 注意事项

1. **属性数量限制**：Setup时需要指定最大属性数量
2. **密钥管理**：需要安全地分发和管理主密钥
3. **属性设计**：需要提前规划好属性的语义和编码
4. **性能考虑**：属性越多，加密/解密时间越长

这就是为什么WKD-IBE需要配合cryptutils包使用的原因——它实现了一个完整的混合加密方案，既保证了安全性，又提供了灵活的访问控制能力。
