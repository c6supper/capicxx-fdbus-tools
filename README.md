### CommonAPI C++ FDBus Tools

##### Copyright
Copyright (C) 2015-2023, Calvin Ke, All rights reserved.

This file is part of COVESA Project IPC Common API C++.
Contributions are licensed to the COVESA under one or more Contribution License Agreements or MPL 2.0.

##### License
This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at http://mozilla.org/MPL/2.0/.

##### CommonAPI C++ Specification and User Guide
The specification document and the user guide can be found in the CommonAPI documentation directory of the CommonAPI-Tools project.

##### Further information
https://covesa.github.io/capicxx-core-tools/

##### Build Instructions for Linux

You can build all code generators by calling maven from the command-line. Open a console and change in the directory org.genivi.commonapi.fdbus.releng of your CommonAPI-Tools directory. Then call:

```bash
mvn -DCOREPATH=<path to your CommonAPI-Tools dir> -Dtarget.id=org.genivi.commonapi.fdbus.target clean verify
```
_COREPATH_ is the directory, that contains the target definition folder: `org.genivi.commonapi.fdbus.target`.

After the successful build you will find the commond-line generators archived in `org.genivi.commonapi.fdbus.cli.product/target/products/commonapi_fdbus_generator.zip` and the update-sites in `org.genivi.commonapi.fdbus.updatesite/target`.
