# Проведение платежа через SberSDK

Функциональность доступна ограниченному кругу наших клиентов, так как находится в тестировании. Чтобы попасть в число ранних пользователей необходимо связаться со своим менеджером и запросить доступ.

- [Настройка оплаты через SberPay с нуля](#чистая-настройка)
- [Переход со старой версии SberPay](#переход-на-новую-версию)

С помощью SDK можно провести и подтвердить платеж через актуальное приложение Сбербанка, если оно установленно, иначе с подтверждением по смс.

## <a name="чистая-настройка"></a> Настройка оплаты через SberPay с нуля

(!) Далее описание настройки метода `SberPay`, если ранее вы его не использовали.

В `TokenizationModuleInputData` необходимо передавать `applicationScheme` – схема для возврата в приложение после успешной оплаты с помощью `SberPay` в приложении Сбербанка.

Пример `applicationScheme`:

```swift
let moduleData = TokenizationModuleInputData(
    ...
    applicationScheme: "examplescheme://"
```

Чтобы провести платёж:

1. При создании `TokenizationModuleInputData` передайте значение `.sberbank` в `paymentMethodTypes`.
2. Получите токен.
3. [Создайте платеж](https://yookassa.ru/developers/api#create_payment) с токеном по API ЮKassa.

Для подтверждения платежа через приложение Сбербанка:

1. В `AppDelegate` импортируйте зависимость `YooKassaPayments`:

   ```swift
   import YooKassaPayments
   ```

2. Добавьте обработку ссылок через `YKSdk` в `AppDelegate`:

```swift
func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?, 
    annotation: Any
) -> Bool {
    return YKSdk.shared.handleOpen(
        url: url,
        sourceApplication: sourceApplication
    )
}
```

3. В `Info.plist` добавьте следующие строки:

```plistbase
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>${BUNDLE_ID}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>examplescheme</string>
        </array>
    </dict>
</array>
```

где `examplescheme` - схема для открытия вашего приложения, которую вы указали в `applicationScheme` при создании `TokenizationModuleInputData`. Через эту схему будет открываться ваше приложение после успешной оплаты с помощью `SberPay`.

4. Добавить в `Info.plist` новые схемы для обращения в сервисам Сбера

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sbolidexternallogin</string>
    <string>sberbankidexternallogin</string>   
</array>
```

и расширенные настройки для http-соединений к сервисам Сбера

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
    <key>gate1.spaymentsplus.ru</key>
    <dict>
       <key>NSExceptionAllowsInsecureHTTPLoads</key>
       <true/>
    </dict>
    <key>ift.gate2.spaymentsplus.ru</key>
    <dict>
       <key>NSExceptionAllowsInsecureHTTPLoads</key>
       <true/>
    </dict>
    <key>cms-res.online.sberbank.ru</key>
       <dict>
           <key>NSExceptionAllowsInsecureHTTPLoads</key>
           <true/>
       </dict>
    </dict>
</dict>
```

5. Реализуйте метод `didFinishConfirmation(paymentMethodType:)` протокола `TokenizationModuleOutput`, который будет вызыван, когда процесс подтверждения будет пройден или пропущен пользователем. На следующем шаге для проверки статуса платежа (прошел ли пользователь подтверждение успешно или нет) используйте [YooKassa API](https://yookassa.ru/developers/api#get_payment)
(см. [Настройка подтверждения платежа](#настройка-подтверждения-платежа)).


## <a name="переход-на-новую-версию"></a> Переход на новую версию SberPay

(!) Далее описание настройки новой версии метода `SberPay`, если ранее вы его уже использовали.

Сценарий оплаты через `Sberpay` теперь происходит не в мобильном приложения, а через встроенное Sber SDK.
Чтобы поддержать новый сценарий достаточно внести несколько изменений в вашем файле `Info.plist`:

1. Заменить схему для обращений в сервисам Сбера

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sberpay</string> 
</array>
```
на обновленную версию
```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sbolidexternallogin</string>
    <string>sberbankidexternallogin</string>   
</array>
```

2. Добавить расширенные настройки для http-соединений к сервисам Сбера

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
    <key>gate1.spaymentsplus.ru</key>
    <dict>
       <key>NSExceptionAllowsInsecureHTTPLoads</key>
       <true/>
    </dict>
    <key>ift.gate2.spaymentsplus.ru</key>
    <dict>
       <key>NSExceptionAllowsInsecureHTTPLoads</key>
       <true/>
    </dict>
    <key>cms-res.online.sberbank.ru</key>
       <dict>
           <key>NSExceptionAllowsInsecureHTTPLoads</key>
           <true/>
       </dict>
    </dict>
</dict>
```
