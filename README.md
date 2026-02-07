# Vello-Personal-Financial-Management-Application
# Vello – Personal Financial Management Application

Vello is a personal financial management application developed as part of the **SDGP (Software Development Group Project)**.  
The application helps users track income and expenses, manage budgets, and gain clear insights into their financial habits through an intuitive and user-friendly interface.

---

## 🚀 Features

- User registration and secure login
- Add, update, and delete income and expense records
- Categorize transactions (Food, Transport, Bills, Entertainment, etc.)
- Monthly and yearly financial summaries
- Budget planning and tracking
- Visual reports (charts and graphs)
- Data persistence using a database
- Responsive and user-friendly UI

---

## 🛠️ Technologies Used

- **Frontend**: HTML, CSS, JavaScript  
- **Backend**: (e.g., Java / Node.js / Python – update as applicable)  
- **Database**: MySQL / MongoDB / SQLite  
- **Version Control**: Git & GitHub  
- **IDE**: Visual Studio Code  

> ✏️ *Update the technology stack if your project uses different tools.*

---

## 📁 Project Structure

Vello/
│
├── README.md                 # Project overview and setup instructions
├── .gitignore                # Files/folders ignored by Git
├── package.json / pom.xml    # Dependency & project config (based on tech stack)
│
├── src/                      # Main source code
│   ├── config/               # App & database configuration
│   │   └── dbConfig.js
│   │
│   ├── controllers/          # Request handling logic
│   │   ├── authController.js
│   │   ├── transactionController.js
│   │   └── budgetController.js
│   │
│   ├── models/               # Data models / entities
│   │   ├── User.js
│   │   ├── Transaction.js
│   │   └── Budget.js
│   │
│   ├── routes/               # Application routes / APIs
│   │   ├── authRoutes.js
│   │   ├── transactionRoutes.js
│   │   └── budgetRoutes.js
│   │
│   ├── services/             # Business logic layer
│   │   └── financeService.js
│   │
│   ├── middlewares/          # Authentication & validation middleware
│   │   └── authMiddleware.js
│   │
│   ├── utils/                # Helper functions
│   │   └── dateUtils.js
│   │
│   └── app.js                # Main application entry point
│
├── public/                   # Frontend static files
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── main.js
│   └── images/
│
├── database/                 # Database-related files
│   ├── schema.sql            # Database schema
│   └── seed.sql              # Sample data
│
├── tests/                    # Test cases
│   ├── unit/
│   └── integration/
│
├── docs/                     # SDGP documentation
│   ├── SRS.pdf
│   ├── Design_Diagrams/
│   └── Test_Plan.pdf
│
└── logs/                     # Application logs
    └── app.log

#License

MIT License

Copyright (c) 2026 Vello Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[vello] flutter create --template app --overwrite .
Creating project ....

Oops; flutter has exited unexpectedly: "PathNotFoundException: Cannot create file, path = 'C:\Users\ASUS VivoBook\OneDrive - Informatics Institute of Technology\Documents\.SANDEEP DOCS (IIT)\SDGP GIT\Vello-Personal-Financial-Management-Application\vello\.gitignore' (OS Error: The system cannot find the file specified, errno = 2)".
A crash report has been written to C:\Users\ASUSVI~1\AppData\Local\Temp\flutter_tools.a41c149c\flutter_01.log
This crash may already be reported. Check GitHub for similar crashes.
https://github.com/flutter/flutter/issues?q=is%3Aissue+PathNotFoundException%3A+Cannot+create+file%2C+path+%3D+%27C%3A%5CUsers%5CASUS+VivoBook%5COneDrive+-+Informatics+Institute+of+Technology%5CDocuments%5C.SANDEEP+DOCS+%28IIT%29%5CSDGP+GIT%5CVello-Personal-Financial-Management-Application%5Cvello%5C.gitignore%27+%28OS+Error%3A+The+system+cannot+find+the+file+specified%2C+errno+%3D+2%29

To report your crash to the Flutter team, first read the guide to filing a bug.
https://flutter.dev/to/report-bugs

Create a new GitHub issue by pasting this link into your browser and completing the issue template. Thank you!
https://github.com/flutter/flutter/issues/new?title=%5Btool_crash%5D+FileSystemException%3A+Cannot+create+file%2C+OS+Error%3A+The+system+cannot+find+the+file+specified%2C+errno+%3D+2&body=%23%23+Command%0A%60%60%60sh%0Aflutter+create+--template+app+--overwrite+.%0A%60%60%60%0A%0A%23%23+Steps+to+Reproduce%0A1.+...%0A2.+...%0A3.+...%0A%0A%23%23+Logs%0AFileSystemException%3A+Cannot+create+file%2C+OS+Error%3A+The+system+cannot+find+the+file+specified%2C+errno+%3D+2%0A%60%60%60console%0A%230++++++_File.throwIfError+%28dart%3Aio%2Ffile_impl.dart%3A783%3A7%29%0A%231++++++_File.createSync+%28dart%3Aio%2Ffile_impl.dart%3A344%3A5%29%0A%232++++++ForwardingFile.createSync+%28package%3Afile%2Fsrc%2Fforwarding%2Fforwarding_file.dart%3A26%3A16%29%0A%233++++++ErrorHandlingFile.createSync.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Fbase%2Ferror_handling_io.dart%3A265%3A22%29%0A%234++++++_runSync+%28package%3Aflutter_tools%2Fsrc%2Fbase%2Ferror_handling_io.dart%3A552%3A14%29%0A%235++++++ErrorHandlingFile.createSync+%28package%3Aflutter_tools%2Fsrc%2Fbase%2Ferror_handling_io.dart%3A264%3A5%29%0A%236++++++Template.render.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Ftemplate.dart%3A350%3A28%29%0A%237++++++_LinkedHashMapMixin.forEach+%28dart%3A_compact_hash%3A765%3A13%29%0A%238++++++Template.render+%28package%3Aflutter_tools%2Fsrc%2Ftemplate.dart%3A310%3A24%29%0A%239++++++CreateBase.renderMerged+%28package%3Aflutter_tools%2Fsrc%2Fcommands%2Fcreate_base.dart%3A431%3A21%29%0A%3Casynchronous+suspension%3E%0A%2310+++++CreateBase.generateApp+%28package%3Aflutter_tools%2Fsrc%2Fcommands%2Fcreate_base.dart%3A454%3A23%29%0A%3Casynchronous+suspension%3E%0A%2311+++++CreateCommand.runCommand+%28package%3Aflutter_tools%2Fsrc%2Fcommands%2Fcreate.dart%3A453%3A31%29%0A%3Casynchronous+suspension%3E%0A%2312+++++FlutterCommand.run.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Frunner%2Fflutter_command.dart%3A1559%3A27%29%0A%3Casynchronous+suspension%3E%0A%2313+++++AppContext.run.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Fbase%2Fcontext.dart%3A154%3A19%29%0A%3Casynchronous+suspension%3E%0A%2314+++++CommandRunner.runCommand+%28package%3Aargs%2Fcommand_runner.dart%3A212%3A13%29%0A%3Casynchronous+suspension%3E%0A%2315+++++FlutterCommandRunner.runCommand.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Frunner%2Fflutter_command_runner.dart%3A487%3A9%29%0A%3Casynchronous+suspension%3E%0A%2316+++++AppContext.run.%3Canonymous+closure%3E+%28package%3Aflutter_tools%2Fsrc%2Fbase%2Fcontext.dart%3A154%3A19%29%0A%3Casynchronous+suspension%3E%0A%60%60%60%0A%60%60%60console%0A%5B%21%5D+Flutter+%28Channel+stable%2C+3.38.9%2C+on+Microsoft+Windows+%5BVersion+10.0.26200.7623%5D%2C+locale+en-US%29+%5B196ms%5D%0A++++%E2%80%A2+Flutter+version+3.38.9+on+channel+stable+at+C%3A%5CUsers%5CASUS+VivoBook%5CDownloads%5Cflutter%0A++++%21+The+flutter+binary+is+not+on+your+path.+Consider+adding+C%3A%5CUsers%5CASUS+VivoBook%5CDownloads%5Cflutter%5Cbin+to+your+path.%0A++++%21+The+dart+binary+is+not+on+your+path.+Consider+adding+C%3A%5CUsers%5CASUS+VivoBook%5CDownloads%5Cflutter%5Cbin+to+your+path.%0A++++%E2%80%A2+Upstream+repository+https%3A%2F%2Fgithub.com%2Fflutter%2Fflutter.git%0A++++%E2%80%A2+Framework+revision+67323de285+%2810+days+ago%29%2C+2026-01-28+13%3A43%3A12+-0800%0A++++%E2%80%A2+Engine+revision+587c18f873%0A++++%E2%80%A2+Dart+version+3.10.8%0A++++%E2%80%A2+DevTools+version+2.51.1%0A++++%E2%80%A2+Feature+flags%3A+enable-web%2C+enable-linux-desktop%2C+enable-macos-desktop%2C+enable-windows-desktop%2C+enable-android%2C+enable-ios%2C+cli-animations%2C+enable-native-assets%2C+omit-legacy-version-file%2C+enable-lldb-debugging%0A++++%E2%80%A2+If+those+were+intentional%2C+you+can+disregard+the+above+warnings%3B+however+it+is+recommended+to+use+%22git%22+directly+to+perform+update+checks+and+upgrades.%0A%0A%5B%E2%9C%93%5D+Windows+Version+%2811+Home+Single+Language+64-bit%2C+25H2%2C+2009%29+%5B751ms%5D%0A%0A%5B%E2%9C%97%5D+Android+toolchain+-+develop+for+Android+devices+%5B26ms%5D%0A++++%E2%9C%97+Unable+to+locate+Android+SDK.%0A++++++Install+Android+Studio+from%3A+https%3A%2F%2Fdeveloper.android.com%2Fstudio%2Findex.html%0A++++++On+first+launch+it+will+assist+you+in+installing+the+Android+SDK+components.%0A++++++%28or+visit+https%3A%2F%2Fflutter.dev%2Fto%2Fwindows-android-setup+for+detailed+instructions%29.%0A++++++If+the+Android+SDK+has+been+installed+to+a+custom+location%2C+please+use%0A++++++%60flutter+config+--android-sdk%60+to+update+to+that+location.%0A%0A%0A%5B%E2%9C%93%5D+Chrome+-+develop+for+the+web+%5B11ms%5D%0A++++%E2%80%A2+Chrome+at+C%3A%5CProgram+Files%5CGoogle%5CChrome%5CApplication%5Cchrome.exe%0A%0A%5B%E2%9C%97%5D+Visual+Studio+-+develop+Windows+apps+%5B10ms%5D%0A++++%E2%9C%97+Visual+Studio+not+installed%3B+this+is+necessary+to+develop+Windows+apps.%0A++++++Download+at+https%3A%2F%2Fvisualstudio.microsoft.com%2Fdownloads%2F.%0A++++++Please+install+the+%22Desktop+development+with+C%2B%2B%22+workload%2C+including+all+of+its+default+components%0A%0A%5B%E2%9C%93%5D+Connected+device+%283+available%29+%5B100ms%5D%0A++++%E2%80%A2+Windows+%28desktop%29+%E2%80%A2+windows+%E2%80%A2+windows-x64++++%E2%80%A2+Microsoft+Windows+%5BVersion+10.0.26200.7623%5D%0A++++%E2%80%A2+Chrome+%28web%29++++++%E2%80%A2+chrome++%E2%80%A2+web-javascript+%E2%80%A2+Google+Chrome+144.0.7559.133%0A++++%E2%80%A2+Edge+%28web%29++++++++%E2%80%A2+edge++++%E2%80%A2+web-javascript+%E2%80%A2+Microsoft+Edge+144.0.3719.82%0A%0A%5B%E2%9C%93%5D+Network+resources+%5B627ms%5D%0A++++%E2%80%A2+All+expected+network+resources+are+available.%0A%0A%21+Doctor+found+issues+in+3+categories.%0A%0A%60%60%60%0A%0A%23%23+Flutter+Application+Metadata%0ANo+pubspec+in+working+directory.%0A&labels=tool%2Csevere%3A+crash
