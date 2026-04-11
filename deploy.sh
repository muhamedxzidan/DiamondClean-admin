#!/bin/bash

# Deploy script for Firebase Hosting - Flutter Web

echo "🚀 بدء عملية Deploy..."
echo "================================"

# 1. بناء تطبيق Flutter Web
echo "📦 بناء تطبيق Flutter Web..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ فشل بناء التطبيق"
    exit 1
fi

echo "✅ تم بناء التطبيق بنجاح"
echo ""

# 2. التحقق من Firebase CLI
echo "🔍 التحقق من Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI غير مثبت. قم بتثبيته:"
    echo "npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI مثبت"
echo ""

# 3. Deploy على Firebase Hosting
echo "🌐 جاري رفع التطبيق على Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo "✅✅✅ تم Deploy بنجاح! 🎉"
    echo "التطبيق الآن متاح على الإنترنت"
else
    echo "❌ فشل Deploy"
    exit 1
fi
