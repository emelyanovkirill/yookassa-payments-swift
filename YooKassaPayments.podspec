Pod::Spec.new do |s|
  s.name      = 'YooKassaPayments'
  s.version   = '6.17.0'
  s.homepage  = 'https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooMoney'
  s.summary = 'YooKassa Payments'

  s.source = { :git => "https://git.yoomoney.ru/scm/sdk/yookassa-payments-swift.git", :tag => "6.17.0" }
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

  s.ios.framework  = 'UIKit'
  s.ios.framework  = 'PassKit'
  s.ios.library = 'z'

  s.ios.dependency 'YooMoneyCoreApi', '~> 3.1'
  s.ios.dependency 'YooKassaPaymentsApi', '~> 2.22.0'
  s.ios.dependency 'YooKassaWalletApi', '~> 2.6.0'
  s.ios.dependency 'MoneyAuth', '~> 10.13.0'
  s.ios.dependency 'YooMoneySessionProfiler', '~> 5.0.4'
  s.ios.dependency 'YooMoneyUI', '~> 7.7'
  s.ios.dependency 'AppMetricaAnalytics', '~> 5.2.0'
  s.ios.dependency 'SPaySDK', '~> 1.0.8'

end