# Hyphen8 Custom Flow LWC Components

A collection of LWC Flow components that we have build to expend the capabilities within flow and to support our end user requirements.
This package comes with an example inactive flow associated with it, this flow is not to be used or activated as it will be updated in future releases as more components are added to this library.

Installation and configuration moved to MSTeams Wiki

# Apex Tools
sf package install --package {latestPackageId} --wait 10 --publish-wait 10


sf package version create --package "Hyphen8LabsFlowComponents" --installation-key-bypass --wait 60 --target-dev-hub H8DevHub --code-coverage

sf package version promote --package {{versionPackageId}} --target-dev-hub {{devHubAlias}}