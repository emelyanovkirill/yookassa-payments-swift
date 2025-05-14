Pod::Spec.new do |s|
  s.name      = 'YooKassaPayments'
  s.version   = '8.0.1'
  s.homepage  = 'https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooMoney'
  s.summary = 'YooKassa Payments'

  s.source = { :git => "https://git.yoomoney.ru/scm/sdk/yookassa-payments-swift.git", :tag => "8.0.1" }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YooKassaPayments/**/*.{h,swift}', 'YooKassaPayments/*.{h,swift}'
  s.ios.resources = [
    'YooKassaPayments/Public/Resources/*.xcassets',
    'YooKassaPayments/Public/Resources/**/*.plist',
    'YooKassaPayments/Public/Resources/**/*.json',
    'YooKassaPayments/Public/Resources/*.lproj/*.strings',
    'YooKassaPayments/Public/Resources/**/Certificates/*.der',
    'YooKassaPayments/Public/Resources/*.xcprivacy'
  ]

  s.pod_target_xcconfig = {
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'OTHER_SWIFT_FLAGS' => '-enable-experimental-feature AccessLevelOnImport',
    'ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS' => 'NO',
  }

  s.ios.framework  = 'UIKit'

  s.ios.dependency 'YooKassaPaymentsApi', '~> 2.25'
  s.ios.dependency 'YooKassaWalletApi', '~> 2.7'
  s.ios.dependency 'MoneyAuth', '~> 12.1'
  s.ios.dependency 'AppMetricaAnalytics', '~> 5.8'
  s.ios.dependency 'SPaySDK', '~> 2.5'
  s.ios.dependency 'FMobileSdk', '~> 2.0.0-1231'
  s.ios.dependency 'YooMoneyPinning'

end