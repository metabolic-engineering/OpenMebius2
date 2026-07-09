function BuildMyApp

    import openmebius.presentation.notification.Notification

    tStart = tic;
    msg = "Building OpenMebius2 application...";
    disp(toLogText(Notification.info(msg)))

    appFile = fullfile(pwd, "OpenMebius2.mlapp");

    exeIcon = fullfile(pwd, "+img", "logo.png");
    exeSplash = fullfile(pwd, "+img", "splash.png");

    system = System();
    latestTag = system.getCurrentVersion();

    msg = "Current version: " + latestTag;
    disp(toLogText(Notification.info(msg)))

    outDir = fullfile(pwd, "../build", "openmebius2");

    buildOpts = compiler.build.StandaloneApplicationOptions( ...
        appFile, ...
        "ExecutableName", "openmebius2", ...
        "ExecutableIcon", exeIcon, ...
        "ExecutableSplashScreen", exeSplash, ...
        "OutputDir", outDir ...
    );

    if strcmp(system.getOperatingSystem(), "Windows")
        buildResults = compiler.build.standaloneWindowsApplication(buildOpts);
    else
        buildResults = compiler.build.standaloneApplication(buildOpts);
    end

    installerIcon = fullfile(pwd, "+img", "logo.png");
    installerSplash = fullfile(pwd, "+img", "splash.png");
    installerLogo = fullfile(pwd, "+img", "sidebar.png");

    filename = system.getFileNameForBinary(latestTag);

    opts = compiler.package.InstallerOptions(buildResults, ...
        "ApplicationName", "OpenMebius2", ...
        "AuthorName", "Tatsumi Imada", ...
        "AuthorEmail", "tatsumi.imada@ist.osaka-u.ac.jp", ...
        "AuthorCompany", "The University of Osaka", ...
        "InstallerName", filename, ...
        "Summary", "GUI application for 13C-metabolic flux analysis.", ...
        "Description", "GUI application for 13C-metabolic flux analysis.", ...
        "InstallerIcon", installerIcon, ...
        "InstallerSplash", installerSplash, ...
        "InstallerLogo", installerLogo, ...
        "OutputDir", fullfile(pwd, "../installer"));

    msg = "Creating installer: " + filename;
    disp(toLogText(Notification.info(msg)))

    compiler.package.installer(buildResults, "Options", opts);

    tEnd = toc(tStart);
    elapsedTime = datetime(0, "ConvertFrom", "epochtime", "Format", "HH:mm:ss");
    elapsedTime.Second = round(tEnd);
    msg = "Build completed in " + string(elapsedTime) + ".";
    disp(toLogText(Notification.info(msg)))

end
