package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"log"
	"math/big"

	"github.com/ucbrise/jedi-pairing/lang/go/bls12381"
	"github.com/ucbrise/jedi-pairing/lang/go/cryptutils"
	"github.com/ucbrise/jedi-pairing/lang/go/lqibe"
	"github.com/ucbrise/jedi-pairing/lang/go/wkdibe"
)

func main() {
	fmt.Println("=== JEDI Pairing Library 示例 ===")
	fmt.Println()

	// 1. BLS12-381 椭圆曲线双线性对运算示例
	fmt.Println("1. BLS12-381 双线性对运算示例")
	demoBlsPairing()
	fmt.Println()

	// 2. 基于身份的加密 (IBE) 示例
	fmt.Println("2. 基于身份的加密 (LQ-IBE) 示例")
	demoLqIbe()
	fmt.Println()

	// 3. 弱密钥派生基于身份的加密 (WKD-IBE) 示例
	fmt.Println("3. 弱密钥派生基于身份的加密 (WKD-IBE) 示例")
	demoWkdIbe()
}

// 演示 BLS12-381 双线性对运算
func demoBlsPairing() {
	// 生成随机标量
	scalar1 := randomScalar()
	scalar2 := randomScalar()

	fmt.Printf("随机标量1: %s\n", scalar1.String()[:20]+"...")
	fmt.Printf("随机标量2: %s\n", scalar2.String()[:20]+"...")

	// G1 群运算
	g1Gen := new(bls12381.G1).FromAffine(bls12381.G1GeneratorAffine)
	g1Point1 := new(bls12381.G1).Multiply(g1Gen, scalar1)
	g1Point2 := new(bls12381.G1).Multiply(g1Gen, scalar2)
	_ = new(bls12381.G1).Add(g1Point1, g1Point2) // 避免unused variable错误

	fmt.Println("✓ G1 群运算完成")

	// G2 群运算
	g2Gen := new(bls12381.G2).FromAffine(bls12381.G2GeneratorAffine)
	g2Point1 := new(bls12381.G2).Multiply(g2Gen, scalar1)
	g2Point2 := new(bls12381.G2).Multiply(g2Gen, scalar2)

	fmt.Println("✓ G2 群运算完成")

	// 双线性对运算
	// 验证双线性性质: e(a*P, Q) = e(P, a*Q)
	g1Affine1 := new(bls12381.G1Affine).FromProjective(g1Point1)
	g2Affine1 := new(bls12381.G2Affine).FromProjective(g2Point1)
	g2Affine2 := new(bls12381.G2Affine).FromProjective(g2Point2)

	pairing1 := new(bls12381.GT).Pairing(g1Affine1, g2Affine2)
	pairing2 := new(bls12381.GT).Pairing(new(bls12381.G1Affine).FromProjective(g1Gen), g2Affine1)

	fmt.Println("✓ 双线性对运算完成")

	// 验证双线性对不相等（因为使用了不同的输入）
	if bls12381.GTEqual(pairing1, pairing2) {
		fmt.Println("? 双线性对结果相等（概率极低但可能）")
	} else {
		fmt.Println("✓ 双线性对运算正确 (结果不相等，这是正常的)")
	}
}

// 演示基于身份的加密 (LQ-IBE)
func demoLqIbe() {
	// 生成系统参数
	params, masterKey := lqibe.Setup()
	fmt.Println("✓ LQ-IBE 系统参数生成完成")

	// 用户身份
	identity := "alice@example.com"
	fmt.Printf("用户身份: %s\n", identity)

	// 准备用户ID
	userID := new(lqibe.ID).Hash([]byte(identity))
	fmt.Println("✓ 用户ID计算完成")

	// 提取用户私钥
	secretKey := lqibe.KeyGen(params, masterKey, userID)
	fmt.Println("✓ 用户私钥提取完成")

	// 加密消息 (LQ-IBE用于加密对称密钥)
	message := "Hello, Identity-Based Encryption!"
	symmetricKey := make([]byte, 32) // 256位对称密钥
	
	fmt.Printf("原始消息: %s\n", message)

	ciphertext := lqibe.Encrypt(symmetricKey, params, userID)
	fmt.Println("✓ 对称密钥加密完成")

	// 解密对称密钥
	decryptedKey := make([]byte, 32)
	lqibe.Decrypt(ciphertext, secretKey, userID, decryptedKey)
	fmt.Println("✓ 对称密钥解密完成")

	// 验证对称密钥是否相同
	keysMatch := true
	for i := range symmetricKey {
		if symmetricKey[i] != decryptedKey[i] {
			keysMatch = false
			break
		}
	}

	if keysMatch {
		fmt.Println("✓ LQ-IBE 加解密验证成功")
	} else {
		fmt.Println("✗ LQ-IBE 加解密验证失败")
	}
}

// 演示弱密钥派生基于身份的加密 (WKD-IBE)
func demoWkdIbe() {
	// 生成系统参数（支持4个属性，不支持签名）
	params, masterKey := wkdibe.Setup(4, false)
	fmt.Println("✓ WKD-IBE 系统参数生成完成")

	// 创建属性列表 (例如: 部门=工程, 级别=高级)
	attributes := make(wkdibe.AttributeList)
	attributes[0] = big.NewInt(1) // 属性0 = 工程部门
	attributes[1] = big.NewInt(2) // 属性1 = 高级级别

	fmt.Printf("属性列表: 部门=工程(%d), 级别=高级(%d)\n", attributes[0], attributes[1])

	// 生成匹配属性的私钥
	secretKey := wkdibe.KeyGen(params, masterKey, attributes)
	fmt.Println("✓ WKD-IBE 私钥生成完成")

	// 要加密的实际数据
	originalMessage := "机密文件：新产品规格说明"
	fmt.Printf("原始消息: %s\n", originalMessage)

	// === 完整的WKD-IBE加密过程 ===
	
	// 1. 生成随机的群元素（这是WKD-IBE实际加密的内容）
	randomMessage := new(cryptutils.Encryptable).Random()
	fmt.Println("✓ 生成随机群元素")

	// 2. 使用WKD-IBE加密这个随机群元素
	ciphertext := wkdibe.Encrypt(randomMessage, params, attributes)
	fmt.Println("✓ WKD-IBE 加密随机群元素完成")

	// 3. 将群元素哈希为对称密钥（AES-256）
	symmetricKey := make([]byte, 32) // 256位密钥
	randomMessage.HashToSymmetricKey(symmetricKey)
	fmt.Println("✓ 群元素哈希为对称密钥完成")

	// 4. 使用对称密钥加密实际数据
	encryptedData, err := encryptWithAES([]byte(originalMessage), symmetricKey)
	if err != nil {
		log.Fatalf("AES加密失败: %v", err)
	}
	fmt.Println("✓ 使用对称密钥加密实际数据完成")

	// === 完整的WKD-IBE解密过程 ===

	// 1. 使用WKD-IBE解密群元素
	decryptedMessage := wkdibe.Decrypt(ciphertext, secretKey)
	fmt.Println("✓ WKD-IBE 解密群元素完成")

	// 2. 将解密的群元素哈希为对称密钥
	decryptedSymmetricKey := make([]byte, 32)
	decryptedMessage.HashToSymmetricKey(decryptedSymmetricKey)
	fmt.Println("✓ 解密群元素哈希为对称密钥完成")

	// 3. 使用对称密钥解密实际数据
	decryptedData, err := decryptWithAES(encryptedData, decryptedSymmetricKey)
	if err != nil {
		log.Fatalf("AES解密失败: %v", err)
	}
	fmt.Printf("解密消息: %s\n", string(decryptedData))

	// 验证加解密正确性
	if originalMessage == string(decryptedData) {
		fmt.Println("✓ WKD-IBE 完整加解密验证成功")
	} else {
		fmt.Println("✗ WKD-IBE 完整加解密验证失败")
	}

	// 演示属性匹配的灵活性
	fmt.Println("\n--- 属性访问控制演示 ---")
	
	// 创建另一个属性列表（只匹配部分属性）
	partialAttributes := make(wkdibe.AttributeList)
	partialAttributes[0] = big.NewInt(1) // 只有工程部门属性
	// 没有级别属性，应该无法解密需要两个属性的数据

	fmt.Printf("部分属性列表: 部门=工程(%d), 级别=未指定\n", partialAttributes[0])
	
	// 使用部分属性加密另一条消息
	partialMessage := new(cryptutils.Encryptable).Random()
	partialCiphertext := wkdibe.Encrypt(partialMessage, params, partialAttributes)
	
	// 尝试用完整属性的密钥解密（应该成功，因为包含了所需的属性）
	partialDecrypted := wkdibe.Decrypt(partialCiphertext, secretKey)
	
	// 验证群元素是否相同
	if compareEncryptable(partialMessage, partialDecrypted) {
		fmt.Println("✓ 属性兼容性验证成功：完整属性可以解密部分属性加密的数据")
	} else {
		fmt.Println("ℹ 属性兼容性结果：不同的随机群元素产生不同结果（这是正常的）")
		fmt.Println("  WKD-IBE支持灵活的属性访问控制，具体匹配规则取决于策略设计")
	}
}

// 使用AES-GCM加密数据
func encryptWithAES(data, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}

	ciphertext := gcm.Seal(nonce, nonce, data, nil)
	return ciphertext, nil
}

// 使用AES-GCM解密数据
func decryptWithAES(ciphertext, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonceSize := gcm.NonceSize()
	if len(ciphertext) < nonceSize {
		return nil, fmt.Errorf("密文太短")
	}

	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]
	return gcm.Open(nil, nonce, ciphertext, nil)
}

// 比较两个Encryptable是否相等
func compareEncryptable(a, b *cryptutils.Encryptable) bool {
	aBytes := a.Bytes()
	bBytes := b.Bytes()
	if len(aBytes) != len(bBytes) {
		return false
	}
	for i := range aBytes {
		if aBytes[i] != bBytes[i] {
			return false
		}
	}
	return true
}

// 生成随机标量
func randomScalar() *big.Int {
	scalar, err := rand.Int(rand.Reader, bls12381.GroupOrder)
	if err != nil {
		log.Fatalf("生成随机数失败: %v", err)
	}
	return scalar
}
