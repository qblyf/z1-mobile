#!/usr/bin/env node
/**
 * TypeScript → Dart 类型生成脚本
 * 
 * 从 z1-mid SDK 的 TypeScript 类型生成 Dart 类型定义
 * 使用方法: node generate-dart-types.js
 * 
 * 依赖: npm install typescript @types/node
 */

const fs = require('fs');
const path = require('path');
const ts = require('typescript');

const SDK_TYPES_DIR = '/Users/fan/www/AI/z1/z1-mid/src/types';
const OUTPUT_DIR = '/Users/fan/www/AI/phone/Flutter/z1-nextapp/z1_mobile/lib/types/api';
const TARGET_FILES = [
  'product-fn-types.ts',
  'product-types.ts',
  'spu-fn-types.ts',
  'spu-types.ts',
  'service-fn-types.ts',
  'service-types.ts',
  'category-types.ts',
  'mall-category-types.ts',
  'member-fn-types.ts',
  'member-types.ts',
  'order-fn-types.ts',
  'order-types.ts',
  'stock-taking-types.ts',
  'transfer-types.ts',
  'purchase-types.ts',
  'approval-fn-types.ts',
  'approval-types.ts',
  'auth-fn-types.ts',
  'auth-types.ts',
  'sku-types.ts',
];

// 类型映射表
const TYPE_MAPPINGS = {
  'number': 'int',
  'string': 'String',
  'boolean': 'bool',
  'any': 'dynamic',
  'void': 'void',
  'never': 'Never',
  'unknown': 'dynamic',
  'object': 'Map<String, dynamic>',
  'Array<': 'List<',
  '[]': '<dynamic>[]',
  'Record<': 'Map<',
  'Promise<': 'Future<',
  '| null': '?',
  ' | null': '?',
  '| undefined': '?',
  ' | undefined': '?',
};

// 简单类型映射（不需要尖括号）
const SIMPLE_MAPPINGS = {
  'number': 'int',
  'string': 'String',
  'boolean': 'bool',
  'any': 'dynamic',
  'void': 'void',
  'never': 'Never',
  'unknown': 'dynamic',
};

/**
 * 转换 TypeScript 类型到 Dart
 */
function convertType(tsType) {
  let result = tsType.trim();
  
  // 1. 处理数组语法 number[] → List<int>, string[] → List<String>
  result = result.replace(/number\[\]/g, 'List<int>');
  result = result.replace(/string\[\]/g, 'List<String>');
  result = result.replace(/boolean\[\]/g, 'List<bool>');
  // 处理其他类型 + [] 数组
  result = result.replace(/(\w+)\[\]/g, (match, type) => {
    const mapped = SIMPLE_MAPPINGS[type] || type;
    return `List<${mapped}>`;
  });
  
  // 2. 处理 Array<type> → List<type>
  result = result.replace(/Array</g, 'List<');
  
  // 3. 处理 Record → Map
  result = result.replace(/Record</g, 'Map<');
  
  // 4. 处理 Promise → Future
  result = result.replace(/Promise</g, 'Future<');
  
  // 5. 处理联合类型
  if (result.includes('|')) {
    const parts = result.split('|');
    const converted = parts.map(p => {
      const trimmed = p.trim();
      // 跳过 null, undefined, never
      if (trimmed === 'null' || trimmed === 'undefined' || trimmed === 'never') {
        return null;
      }
      // 处理联合类型中的简单类型
      if (trimmed === 'number') return 'int';
      if (trimmed === 'string') return 'String';
      if (trimmed === 'boolean') return 'bool';
      return trimmed;
    }).filter(Boolean);
    
    if (converted.length === 0) return 'dynamic';
    if (converted.length === 1) result = converted[0] + '?';
    else result = converted.join(' | ') + '?';
    return result;
  }
  
  // 6. 简单类型映射
  if (result === 'number') return 'int';
  if (result === 'string') return 'String';
  if (result === 'boolean') return 'bool';
  if (result === 'any') return 'dynamic';
  if (result === 'void') return 'void';
  if (result === 'never') return 'Never';
  if (result === 'unknown') return 'dynamic';
  
  return result;
}

/**
 * 解析 TypeScript 文件并提取类型定义
 */
function parseTypeScriptFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const sourceFile = ts.createSourceFile(
    filePath,
    content,
    ts.ScriptTarget.Latest,
    true
  );
  
  const types = [];
  const interfaces = [];
  const functions = [];
  
  function visit(node) {
    // 类型别名: type X = ...
    if (ts.isTypeAliasDeclaration(node)) {
      const name = node.name.text;
      const typeNode = node.type;
      const typeStr = typeNode.getText();
      
      // 跳过函数类型
      if (ts.isFunctionTypeNode(typeNode)) {
        // 提取函数签名
        const signatures = typeNode.parameters.map(param => {
          const paramName = param.name.text;
          const paramType = convertType(param.type.getText());
          return `${paramName}: ${paramType}`;
        }).join(', ');
          
        functions.push({
          name,
          params: signatures,
          returnType: convertType(typeNode.type.getText())
        });
      } else {
        types.push({
          name,
          type: convertType(typeStr)
        });
      }
    }
    
    // 接口定义: interface X { ... }
    if (ts.isInterfaceDeclaration(node)) {
      const name = node.name.text;
      const members = node.members.map(member => {
        if (ts.isPropertySignature(member)) {
          const propName = member.name.text;
          let propType = member.type 
            ? convertType(member.type.getText())
            : 'dynamic';
          
          // 检查是否可选
          const isOptional = member.questionToken !== undefined;
          
          return {
            name: propName,
            type: propType,
            optional: isOptional
          };
        }
        return null;
      }).filter(Boolean);
      
      interfaces.push({ name, members });
    }
    
    ts.forEachChild(node, visit);
  }
  
  visit(sourceFile);
  
  return { types, interfaces, functions };
}

/**
 * 生成 Dart 类型文件
 */
function generateDartFile(moduleName, parsed) {
  const { types, interfaces, functions } = parsed;
  
  let dartCode = `// ============================================================
// Auto-generated from z1-mid SDK types
// DO NOT EDIT MANUALLY
// Generated at: ${new Date().toISOString()}
// ============================================================

import 'package:dio/dio.dart';

// re-export common types
export 'package:z1_mobile/types/common.dart';

`;

  // 添加接口
  for (const iface of interfaces) {
    dartCode += `class ${iface.name} {\n`;
    for (const member of iface.members) {
      const optionalMark = member.optional ? '?' : '';
      dartCode += `  final ${member.type}${optionalMark} ${member.name};\n`;
    }
    dartCode += `\n  ${iface.name}({\n`;
    for (const member of iface.members) {
      const thisMark = member.optional ? 'this.' : 'required this.';
      dartCode += `    ${thisMark}${member.name},\n`;
    }
    dartCode += `  });\n`;
    
    // 添加 fromJson 工厂方法
    dartCode += `\n  factory ${iface.name}.fromJson(Map<String, dynamic> json) {\n`;
    dartCode += `    return ${iface.name}(\n`;
    for (const member of iface.members) {
      dartCode += `      ${member.name}: json['${member.name}'] as ${member.type}${member.optional ? '?' : ''},\n`;
    }
    dartCode += `    );\n`;
    dartCode += `  }\n`;
    
    // 添加 toJson 方法
    dartCode += `\n  Map<String, dynamic> toJson() {\n`;
    dartCode += `    return {\n`;
    for (const member of iface.members) {
      dartCode += `      '${member.name}': ${member.name},\n`;
    }
    dartCode += `    };\n`;
    dartCode += `  }\n`;
    dartCode += `}\n\n`;
  }
  
  // 添加类型别名
  for (const t of types) {
    dartCode += `// type ${t.name} = ${t.type}\n`;
  }
  
  return dartCode;
}

/**
 * 主函数
 */
function main() {
  console.log('🚀 Starting TypeScript → Dart type generation...\n');
  
  // 确保输出目录存在
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log(`📁 Created output directory: ${OUTPUT_DIR}\n`);
  }
  
  let generatedCount = 0;
  
  for (const file of TARGET_FILES) {
    const filePath = path.join(SDK_TYPES_DIR, file);
    
    if (!fs.existsSync(filePath)) {
      console.log(`⚠️  Skipping (not found): ${file}`);
      continue;
    }
    
    console.log(`📄 Processing: ${file}`);
    
    try {
      const parsed = parseTypeScriptFile(filePath);
      const moduleName = file.replace('.ts', '').replace('-fn', '');
      const dartCode = generateDartFile(moduleName, parsed);
      
      const outputPath = path.join(OUTPUT_DIR, `${moduleName}.dart`);
      fs.writeFileSync(outputPath, dartCode);
      
      console.log(`   ✅ Generated: ${path.basename(outputPath)}`);
      console.log(`   - Interfaces: ${parsed.interfaces.length}`);
      console.log(`   - Types: ${parsed.types.length}`);
      console.log(`   - Functions: ${parsed.functions.length}\n`);
      
      generatedCount++;
    } catch (err) {
      console.error(`   ❌ Error processing ${file}: ${err.message}\n`);
    }
  }
  
  console.log('─'.repeat(50));
  console.log(`\n✅ Done! Generated ${generatedCount} files`);
  console.log(`📁 Output: ${OUTPUT_DIR}\n`);
  
  // 生成 index 文件
  const indexContent = `// Type exports
export 'product.dart';
export 'spu.dart';
export 'service.dart';
export 'category.dart';
export 'mall-category.dart';
export 'member.dart';
export 'order.dart';
export 'stock-taking.dart';
export 'transfer.dart';
export 'purchase.dart';
export 'approval.dart';
export 'auth.dart';
export 'sku.dart';
`;

  fs.writeFileSync(path.join(OUTPUT_DIR, 'api.dart'), indexContent);
  console.log('📄 Generated index file: api.dart');
}

main();
