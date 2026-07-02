cmake_minimum_required(VERSION 3.24)
project(yas-pacman VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Test)
qt_standard_project_setup(REQUIRES 6.5)

# ---- Vendored YAS core (self-contained; kept in sync across the suite) ------
qt_add_library(yascore STATIC
    src/core/package.h
    src/core/clicommand.h
    src/core/packagemanageradapter.h
    src/core/processrunner.h src/core/processrunner.cpp
    src/core/commandlog.h src/core/commandlog.cpp
    src/core/operationqueue.h src/core/operationqueue.cpp
    src/core/clidetector.h src/core/clidetector.cpp
    src/core/packagelistmodel.h src/core/packagelistmodel.cpp
    src/core/appcontroller.h src/core/appcontroller.cpp
    src/core/bootstrap.h src/core/bootstrap.cpp
    src/core/thememanager.h src/core/thememanager.cpp
)
target_include_directories(yascore PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/core)
target_link_libraries(yascore PUBLIC
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2)

set_source_files_properties(qml/core/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
qt_add_qml_module(yascoreui
    URI Yas.Core
    VERSION 1.0
    STATIC
    QML_FILES
        qml/core/Theme.qml
        qml/core/YasAppWindow.qml
        qml/core/components/TagBadge.qml
        qml/core/components/AccentButton.qml
        qml/core/components/SearchBar.qml
        qml/core/components/PackageDelegate.qml
        qml/core/components/PackageBrowser.qml
        qml/core/components/DetailPane.qml
        qml/core/components/TerminalView.qml
        qml/core/components/SummaryCard.qml
        qml/core/components/IconButton.qml
        qml/core/components/ThemedSwitch.qml
        qml/core/components/FeaturedView.qml
        qml/core/views/HomeView.qml
        qml/core/views/ExplorerView.qml
        qml/core/views/InstalledView.qml
        qml/core/views/UpdatesView.qml
        qml/core/views/ActionsView.qml
        qml/core/views/HistoryView.qml
        qml/core/views/SettingsView.qml
)
target_link_libraries(yascoreui PUBLIC yascore)

# ---- App ---------------------------------------------------------------------
qt_add_executable(yas-pacman
    src/main.cpp
    src/pacmanadapter.h src/pacmanadapter.cpp
)
qt_add_qml_module(yas-pacman
    URI YasPacman
    VERSION 1.0
    QML_FILES qml/Main.qml
)
target_link_libraries(yas-pacman PRIVATE yascore yascoreui yascoreuiplugin)

# Suite fonts (bundled when present under assets/fonts)
file(GLOB YAS_FONTS ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/*.ttf)
if(YAS_FONTS)
    qt_add_resources(yas-pacman "yas_fonts"
        PREFIX "/yas/fonts"
        BASE ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts
        FILES ${YAS_FONTS})
endif()

# Featured storefront mock (later replaced by the yas-web API)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/assets/featured.json)
    qt_add_resources(yas-pacman "yas_featured"
        PREFIX "/yas"
        BASE ${CMAKE_CURRENT_SOURCE_DIR}/assets
        FILES ${CMAKE_CURRENT_SOURCE_DIR}/assets/featured.json)
endif()

# ---- Platform packaging hints ---------------------------------------------------
if(WIN32)
    set_target_properties(yas-pacman PROPERTIES WIN32_EXECUTABLE TRUE)
endif()
if(APPLE)
    set_target_properties(yas-pacman PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "YAS Pacman"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.albertolicea00.yas-pacman"
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    )
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/icons/app.icns)
        set_target_properties(yas-pacman PROPERTIES MACOSX_BUNDLE_ICON_FILE app.icns)
        target_sources(yas-pacman PRIVATE icons/app.icns)
        set_source_files_properties(icons/app.icns PROPERTIES
            MACOSX_PACKAGE_LOCATION Resources)
    endif()
endif()

# ---- Tests ----------------------------------------------------------------------
enable_testing()
add_subdirectory(tests)
