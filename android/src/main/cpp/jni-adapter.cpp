#include "TiptapParser.hpp"
#include <android/log.h>
#include <jni.h>
#include <string>

using namespace Tiptap;

#ifdef LOG_TAG
#undef LOG_TAG
#endif
#define LOG_TAG "RenderRichTextJNI"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static jint nodeTypeToJavaOrdinal(NodeType type) {
  switch (type) {
    case NodeType::Document:
      return 0;
    case NodeType::Paragraph:
      return 1;
    case NodeType::Text:
      return 2;
    case NodeType::Link:
      return 3;
    case NodeType::Heading:
      return 4;
    case NodeType::LineBreak:
      return 5;
    case NodeType::Strong:
      return 6;
    case NodeType::Emphasis:
      return 7;
    case NodeType::Strikethrough:
      return 8;
    case NodeType::Underline:
      return 9;
    case NodeType::Code:
      return 10;
    case NodeType::Image:
      return 11;
    case NodeType::Blockquote:
      return 12;
    case NodeType::UnorderedList:
      return 13;
    case NodeType::OrderedList:
      return 14;
    case NodeType::ListItem:
      return 15;
    case NodeType::CodeBlock:
      return 16;
    case NodeType::ThematicBreak:
      return 17;
    case NodeType::Table:
      return 18;
    case NodeType::TableHead:
      return 19;
    case NodeType::TableBody:
      return 20;
    case NodeType::TableRow:
      return 21;
    case NodeType::TableHeaderCell:
      return 22;
    case NodeType::TableCell:
      return 23;
    case NodeType::LatexMathInline:
      return 24;
    case NodeType::LatexMathDisplay:
      return 25;
    case NodeType::Spoiler:
      return 26;
    case NodeType::Superscript:
      return 27;
    case NodeType::Subscript:
      return 28;
    case NodeType::Highlight:
      return 29;
    case NodeType::SoftBreak:
      return 30;
    case NodeType::BlankLine:
      return 31;
    case NodeType::Admonition:
      return 32;
    case NodeType::Video:
      return 33;
    case NodeType::Factoid:
      return 34;
    default:
      return 0;
  }
}

static jobject createJavaNode(JNIEnv *env, const std::shared_ptr<TiptapASTNode> &node) {
  if (!node) {
    return nullptr;
  }

  jclass nodeClass = env->FindClass("com/renderrichtext/parser/TiptapASTNode");
  if (!nodeClass) {
    LOGE("Failed to find TiptapASTNode class");
    return nullptr;
  }

  jclass nodeTypeClass = env->FindClass("com/renderrichtext/parser/TiptapASTNode$NodeType");
  if (!nodeTypeClass) {
    LOGE("Failed to find NodeType enum class");
    return nullptr;
  }

  jmethodID valuesMethod = env->GetStaticMethodID(
      nodeTypeClass, "values", "()[Lcom/renderrichtext/parser/TiptapASTNode$NodeType;");
  if (!valuesMethod) {
    LOGE("Failed to find NodeType.values() method");
    return nullptr;
  }

  jobjectArray enumValues = (jobjectArray)env->CallStaticObjectMethod(nodeTypeClass, valuesMethod);
  if (!enumValues) {
    LOGE("Failed to get NodeType enum values");
    return nullptr;
  }

  jint ordinal = nodeTypeToJavaOrdinal(node->type);
  jobject nodeTypeEnum = env->GetObjectArrayElement(enumValues, ordinal);
  if (!nodeTypeEnum) {
    LOGE("Failed to get NodeType enum value at index %d", ordinal);
    return nullptr;
  }

  jstring contentStr = env->NewStringUTF(node->content.c_str());

  jclass mapClass = env->FindClass("java/util/HashMap");
  jmethodID mapInit = env->GetMethodID(mapClass, "<init>", "(I)V");
  jmethodID mapPut = env->GetMethodID(mapClass, "put", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");
  jobject attributesMap = env->NewObject(mapClass, mapInit, static_cast<jint>(node->attributes.size()));
  for (const auto &pair : node->attributes) {
    jstring key = env->NewStringUTF(pair.first.c_str());
    jstring value = env->NewStringUTF(pair.second.c_str());
    env->CallObjectMethod(attributesMap, mapPut, key, value);
    env->DeleteLocalRef(key);
    env->DeleteLocalRef(value);
  }

  jclass listClass = env->FindClass("java/util/ArrayList");
  jmethodID listInit = env->GetMethodID(listClass, "<init>", "(I)V");
  jmethodID listAdd = env->GetMethodID(listClass, "add", "(Ljava/lang/Object;)Z");
  jobject childrenList = env->NewObject(listClass, listInit, static_cast<jint>(node->children.size()));
  for (const auto &child : node->children) {
    jobject childObj = createJavaNode(env, child);
    if (childObj) {
      env->CallBooleanMethod(childrenList, listAdd, childObj);
      env->DeleteLocalRef(childObj);
    }
  }

  jmethodID constructor = env->GetMethodID(
      nodeClass, "<init>",
      "(Lcom/renderrichtext/parser/TiptapASTNode$NodeType;Ljava/lang/String;Ljava/util/Map;Ljava/util/List;)V");
  if (!constructor) {
    LOGE("Failed to find TiptapASTNode constructor");
    return nullptr;
  }

  jobject javaNode = env->NewObject(nodeClass, constructor, nodeTypeEnum, contentStr, attributesMap, childrenList);

  env->DeleteLocalRef(nodeTypeClass);
  env->DeleteLocalRef(enumValues);
  env->DeleteLocalRef(nodeTypeEnum);
  if (contentStr) {
    env->DeleteLocalRef(contentStr);
  }
  env->DeleteLocalRef(attributesMap);
  env->DeleteLocalRef(childrenList);
  env->DeleteLocalRef(nodeClass);
  return javaNode;
}

extern "C" JNIEXPORT jobject JNICALL Java_com_renderrichtext_parser_Parser_nativeParseDocument(JNIEnv *env, jclass,
                                                                                               jstring document) {
  if (document == nullptr) {
    return nullptr;
  }
  const char *utf8 = env->GetStringUTFChars(document, nullptr);
  if (utf8 == nullptr) {
    return nullptr;
  }
  std::string json(utf8);
  env->ReleaseStringUTFChars(document, utf8);
  auto ast = parseTiptapDocument(json);
  return createJavaNode(env, ast);
}
