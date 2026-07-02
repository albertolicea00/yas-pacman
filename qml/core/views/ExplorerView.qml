import QtQuick
import Yas.Core

// Search the remote catalog; shows the featured storefront until the first
// search returns results.
PackageBrowser {
    id: explorer
    title: qsTr("Explore")
    model: App.searchModel
    placeholder: qsTr("Search packages (press Enter)")
    emptyText: qsTr("Search to explore available packages")
    onSearch: query => App.search(query)
    emptyContent: YasManager.showFeatured ? featuredComponent : null

    Component {
        id: featuredComponent
        FeaturedView {
            onPackageTapped: (packageId, kind) => App.search(packageId)
        }
    }
}
