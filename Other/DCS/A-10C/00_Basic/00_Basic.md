# Basic

发动机检测仪表（EMI）以$x(0 \rightarrow 3), y(0 \uparrow 2)$的方式排列，即：

1. `ITT`（涡轮间温度）表示为`[0,2]`；
2. 油压指示器表示为`[0,0]`。

## 一、启动

### 1.1 上电并启动APU

在完成飞行前检查后，你需要开启飞机电源并启动APU。在启动APU之前，你需要接通电力。首先确保`Right Console`外前侧的`Battery Switch`设置为 `PWR`，且`Right Console`外前侧`Inverter Switch`（逆变器开关）设置为`STBY`。

#### 1.1.1 上电操作

1. 将`Battery switch`拨至`PWR`位置。
    - 位于`Right Console`外前侧`Electrical Power Panel`；
    - 这将允许从蓄电池抽取直流电，并向直流主母线和辅助母线供电。APU启动时将从直流主母线抽取电力。
2. 将`Instrument Inverter Switch`从`OFF`位置拨至`STBY`位置。
    - 位于`Right Console`外前侧`Electrical Power Panel`；
    - 这将允许把APU生成的直流电逆变为交流电，从而为许多仪表供电的交流母线提供电力。启用后，`Right Console`外前侧警告面板的`INST INV`（仪表逆变器）警告灯应当熄灭。
3. 如果是夜间，开启的应急泛光灯开关（`Emergency Flood Light switch`）以照亮座舱。
    - 位于`Right Console`外前侧`Electrical Power Panel`；
4. 将供氧杆拨到`ON`；
    - 位于`Right Console`中外侧，`Oxygen Regulator -> Supply Lever`。

#### 1.1.2 检查

1. 警告面板上的`INST INV`（仪表逆变器）、`L/R ENG HOT`（左/右发动机过热）指示灯应当熄灭。
2. `EMI[0,2]`的发动机`ITT`表读数应当低于$180^\circ\text{C}$。
3. `Front Dash`左侧，的起落架放下指示灯为**绿色**；
4. `Left Console`外前侧，按下`Signal Lights`（信号灯测试）按钮来测试信号灯；
5. `Front Dash`左下方，如果需要，校准时钟；
6. `Front Dash`右侧，测试燃油量指示器。按下测试按钮`TEST IND`，左/右指针应指示在3,000磅，总计读数应显示6,000磅。

#### 1.1.3 启动APU

1. 将两个交流发电机开关（`AC Generator switches`）打到`PWR`。
    - 位于`Right Console`外前侧`Electrical Power Panel`；
    - 设置好后，一旦发动机运转并驱动发电机，发电机就会向交流母线输送交流电。
2. 将所有燃油泵（`Boost Pumps`）打到`On`
    - 位于`Left Console`内前侧`Fuel System Control Panel`；
    - 注意，有主/翼、左/右，一共4个开关；
3. 将`APU Start`打到`On`；
    - 位于`Left Console`内中侧`Throttles Panel`；
    - 一旦稳定运转，APU就能够提供引气来启动发动机，并驱动APU发电机。当APU为发动机启动机提供动力时，APU排气温度（EGT）会短暂飙升至$760^\circ\text{C}$，但在怠速时会恢复到$400^\circ\text{C}$至$450^\circ\text{C}$之间。APU稳定运行时的转速将为$100\%$。
4. 将`APU Generator switch`打到`PWR`；
    - 位于`Right Console`外前侧`Electrical Power Panel`；

### 1.2 设置无线电

TODO

### 1.3 设置航空辅助面板

位于右侧控制台CDU（控制显示单元）下方的这个小面板，需要针对导航系统进行设置。尽早进行这一步是一个好主意，因为这样可以给惯性导航系统（INS）留出足够的对准时间。

1. 将`PAGE`（页面）旋钮转到`OTHER`；
    - 这将允许我们在CDU上电时，查看CDU的内置自检（BIT）和初始化检查。
2. 将`CDU Switch`（控制显示单元，左侧Switch）拨至`ON`；
    - 这将为位于AAP上方的CDU面板供电。在CDU显示屏窗口上，将开始执行CDU启动内置自检（BIT）。完成后，CDU将显示对准（Alignment）页面。
3. 将`EGI Switch`（嵌入式GPS/INS，右侧Switch）拨至`ON`；
    - 这将启动惯性导航系统和全球定位系统，并开始对准流程，该流程可能会持续几分钟。

和F-16C依赖于MMC进行航点管理不同，CDU（Control Display Unit）本身就是一台独立的、功能强大的导航与任务计算机。它负责管理整架飞机所有的航路点、飞行计划、初始位置、以及风向计算等。

### 1.3 启动引擎

#### 1.3.1 左

1. 确认两个发动机工作开关（`Engine Operate switches`）均处于`NORM`（中间位置）；
    - 位于`Left Console`内中侧`Throttles Panel`；
2. 将左油门从`OFF`推到`IDLE`，此时发动机转速在$56\%$位置；
3. 检查`Front Dash`右侧的“左液压系统指示器”。正常压力应在$2,800$至$3,350 psi$之间；

#### 1.3.2 右

1. 当左发动机稳定后，将右油门从`OFF`推到`IDLE`；
    - 注意：启动发动机时，涡轮间温度（ITT）会短暂飙升至$900^\circ\text{C}$，但随后会稳定在$275^\circ\text{C}$至$865^\circ\text{C}$之间。
2. 将襟翼放下，然后放回全收，来检查左液压系统。同时监控液压系统指示器。
    - 位于`Left Console`内中侧`Throttles Panel`，油门把手的外侧，白色拨杆，有三个挡位：
        - `UP`（全收）：最前。
        - `MVR`（机动，$7\degree$）：中间。在格斗、低速盘旋时使用。
        - `DN`（降落，$20\degree$）：最后。在启动检查和起降时使用。
3. 检查减速板；
    - 同样位于油门HOTAS上；
4. 当两台发动机稳定运行之后，手动地将`APU Start`打到`OFF`
    - 位于`Left Console`内中侧`Throttles Panel`；

F/A-18C在启动一台引擎后（一般是右发），当右发转速一到，它的发电机自动并网。中央电力管理系统（Ammeter/Bus Control），会自动断开并关掉供电能力较弱的APU。通常，大黄蜂或者民航客机常用Cross-bleed start来启动第二台发动机，但A-10C采用APU驱动。即A-10C的第二个发动机引气依然由APU提供，而不是第一台已经启动的引擎，这是为了避免电网波动、发动机过热导致航电断电，或是对地勤人员产生安全影响。

当A-10C的两台引擎都处于IDLE时，由于没有负责电网平衡负载的计算机，此时应该手动关闭APU，防止供电冲突。