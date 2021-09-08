<AutoPilot:project xmlns:AutoPilot="com.autoesl.autopilot.project" top="dfr_inference" name="proj_dfr_core">
    <includePaths/>
    <libraryFlag/>
    <files>
        <file name="../../dfr_core_test.cpp" sc="0" tb="1" cflags=" -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="mackey_glass.cpp" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="dfr_core.cpp" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
    </files>
    <solutions>
        <solution name="dfr_core_solution" status=""/>
    </solutions>
    <Simulation argv="">
        <SimFlow name="csim" setup="false" optimizeCompile="false" clean="false" ldflags="" mflags=""/>
    </Simulation>
</AutoPilot:project>

