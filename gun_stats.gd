extends Node

enum GunType {
    HANDGUN,
    SHOTGUN,
    RIFLE
}

enum GunStat {
    PRECISION_HIP, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 15 pixels
    PRECISION_AIM, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 10 pixels
    RECOIL, # 0 to 1, where 0 is 0 recoil and 1 is 40 pixels
}

const GUN_STATS: Dictionary = {
    GunType.HANDGUN: {
        GunStat.PRECISION_HIP: 0.9,
        GunStat.PRECISION_AIM: 1.0,
        GunStat.RECOIL: 0.3,
    },
    GunType.SHOTGUN: {
        GunStat.PRECISION_HIP: 0,
        GunStat.PRECISION_AIM: 0.2,
        GunStat.RECOIL: 0.8,
    },
    GunType.RIFLE: {
        GunStat.PRECISION_HIP: 0.2,
        GunStat.PRECISION_AIM: 2.5,
        GunStat.RECOIL: 0.5,
    }
}