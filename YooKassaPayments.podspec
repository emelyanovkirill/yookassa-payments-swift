Pod::Spec.new do |s|
  s.name      = 'YooKassaPayments'
  s.version   = '6.9.2'
  s.homepage  = 'https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooMoney'
  s.summary = 'YooKassa Payments'

  s.source = { :git => "https://git.yoomoney.ru/scm/sdk/yookassa-payments-swift.git", :tag => "6.9.2" }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YooKassaPayments/**/*.{h,swift}', 'YooKassaPayments/*.{h,swift}'
  s.ios.resources = [
    'YooKassaPayments/Public/Resources/*.xcassets',
    'YooKassaPayments/Public/Resources/**/*.plist',
    'YooKassaPayments/Public/Resources/**/*.json',
    'YooKassaPayments/Public/Resources/*.lproj/*.strings'
  ]

  s.ios.framework  = 'UIKit'
  s.ios.framework  = 'PassKit'
  s.ios.library = 'z'

  s.ios.dependency 'YooMoneyCoreApi', '~> 2.1.0'
  s.ios.dependency 'TMXProfiling', '= 1.0.1'
  s.ios.dependency 'TMXProfilingConnections', '= 1.0.1'
  s.ios.dependency 'YooKassaPaymentsApi', '~> 2.11.0'
  s.ios.dependency 'YooKassaWalletApi', '~> 2.3.1'
  s.ios.dependency 'MoneyAuth', '~> 5.0.0'
  s.ios.dependency 'ThreatMetrixAdapter', '~> 3.3.3'
  s.ios.dependency 'YooMoneyUI', '~> 5.0'
  s.ios.dependency 'YandexMobileMetrica/Dynamic', '>= 3.0'

end