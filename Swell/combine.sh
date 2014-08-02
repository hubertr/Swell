#!/bin/sh
# Hey noob, to run a script you just created, you need to "chmod 775 file.sh" on it
# Hey noob, apparently you can "chmod +x file.sh" too
rm ../SwellAll.swift
cat LogLevel.swift Formatter.swift LogLocation.swift Logger.swift LogSelector.swift Swell.swift > SwellTemp.swift
#sed '1!{/^import Foundation/d;}' SwellAll.swift
awk '!/^import Foundation/ || ++n <= 1'  SwellTemp.swift > ../SwellAll.swift
rm SwellTemp.swift
echo Done