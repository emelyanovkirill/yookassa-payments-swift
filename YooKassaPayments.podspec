Pod::Spec.new do |s|
  s.name      = 'YooKassaPayments'
  s.version   = '6.14.0'
  s.homepage  = 'https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooMoney'
  s.summary = 'YooKassa Payments'

  s.source = { :git => "https://git.yoomoney.ru/scm/sdk/yookassa-payments-swift.git", :tag => "6.14.0" }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YooKassaPayments/**/*.{h,swift}', 'YooKassaPayments/*.{h,swift}'
  s.ios.resources = [
    'YooKassaPayments/Public/Resources/*.xcassets',
    'YooKassaPayments/Public/Resources/**/*.plist',
    'YooKassaPayments/Public/Resources/**/*.json',
    'YooKassaPayments/Public/Resources/*.lproj/*.strings',
    'YooKassaPayments/Public/Resources/**/Certificates/*.der'
  ]

  s.ios.framework  = 'UIKit'
  s.ios.framework  = 'PassKit'
  s.ios.library = 'z'

  s.ios.dependency 'YooMoneyCoreApi', '~> 3.0'
  s.ios.dependency 'YooKassaPaymentsApi', '~> 2.21.2'
  s.ios.dependency 'YooKassaWalletApi', '~> 2.3.1'
  s.ios.dependency 'MoneyAuth', '~> 10.2.1'
  s.ios.dependency 'YooMoneySessionProfiler', '~> 5.0.1'
  s.ios.dependency 'YooMoneyUI', '~> 7.3.1'
  s.ios.dependency 'YandexMobileMetrica/Dynamic', '>= 3.0'
  s.ios.dependency 'SPaySDK', '~> 1.0.8'

end