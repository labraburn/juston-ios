# [JUSTON](https://apps.apple.com/app/id1629214799) - non custodial TON wallet for iOS platfrom

## Building

1. Open `project/JUSTON.xcodeproj`

2. Change `project/iOS/Supporting/Configurations/Debug.xcconfig`

```
DEVELOPMENT_TEAM = ${YOUR_TEAM_ID}
PRODUCT_BUNDLE_IDENTIFIER = ${YOUR_BUNDLE_ID}
```

3. Change `project/iOS/Supporting/Entitlements/Debug.entitlements`

```
<key>com.apple.security.application-groups</key>
<array>
	<string>${YOUR_APPLICATION_ACCESS_GROUP}</string>
</array>
<key>keychain-access-groups</key>
<array>
	<string>$(AppIdentifierPrefix)${YOUR_KEYCHAIN_ACCESS_GROUP}</string>
</array>
```

4. Change next files with parameters from step above:

- `packages/JustonCORE/Sources/JustonCORE/AccessGroup/FileManagerAccessGroup.swift`
- `packages/JustonCORE/Sources/JustonCORE/AccessGroup/KeychainAccessGroup.swift`
- `packages/JustonCORE/Sources/JustonCORE/AccessGroup/UserDefaultsAccessGroup.swift`

5. Run build.

## Bug reports

- Please, use [issue](https://github.com/labraburn/juston-ios/issues/new?assignees=&labels=Bug+Report&template=bug_report.yaml) template for it.

## Contacts

- anton@labraburn.com
