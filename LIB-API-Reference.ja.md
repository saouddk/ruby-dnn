# LIB-APIリファレンス
ruby-dnnの付属ライブラリのリファレンスです。  
対応バージョン:0.1.6


# dnn/lib/mnist
MNISTデータセットを扱うライブラリです。初回利用時は、データセットのダウンロードを行うため、時間がかかります。


# module MNIST
MNISTを扱うモジュールです。

## 【Singleton methods】

## def self.load_train
トレーニング用データを取得します。
### arguments
なし。
### return
Array  
[イメージデータ, ラベルデータ]の形式で取得します。
* イメージデータ
  UInt8の[60000, 28, 28]の形式
* テストデータ
  UInt8の[60000]の形式

## def self.load_test
テスト用データを取得します。
### arguments
なし。
### return
Array  
[イメージデータ, ラベルデータ]の形式で取得します。
* イメージデータ
  UInt8の[10000, 28, 28]の形式
* テストデータ
  UInt8の[10000]の形式


# dnn/lib/cifar10
CIFAR-10データセットを扱うライブラリです。初回利用時は、データセットのダウンロードを行うため、時間がかかります。


# module CIFAR10
CIFAR-10を扱うモジュールです。

## 【Singleton methods】

## def self.load_train
トレーニング用データを取得します。
### arguments
なし。
### return
Array  
[イメージデータ, ラベルデータ]の形式で取得します。
* イメージデータ
  UInt8の[50000, 32, 32, 3]の形式
* テストデータ
  UInt8の[50000]の形式

## def self.load_test
テスト用データを取得します。
### arguments
なし。
### return
Array  
[イメージデータ, ラベルデータ]の形式で取得します。
* イメージデータ
  UInt8の[10000, 32, 32, 3]の形式
* テストデータ
  UInt8の[10000]の形式


# dnn/lib/image_io
画像のin/outを行うライブラリです。内部でstb_imageとstb_image_writeを使用しています。


# module ImageIO

## def self.read(file_name)
画像をNumo::UInt8形式で読み込みます。
### arguments
* String file_name  
読み込む画像のファイル名。
### return
Numo::UInt8  
[width, height, rgb]のNumo::UInt8配列。

## def self.write(file_name, nary, quality: 100)
Numo::UInt8形式の画像を書き込みます。
### arguments
* String file_name  
書き込む画像のファイル名。
* Numo::UInt8  
[width, height, rgb]のNumo::UInt8配列。
* Integer quality: 100
画像をJPEGで書き込む場合のクオリティ。