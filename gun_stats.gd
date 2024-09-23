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
    MAGAZINE_COUNT, # 0 to infinity, where 0 is infinite magazine count
    MAGAZINE_SIZE, # 0 to infinity, where 0 is infinite magazine size
    RELOAD_TIME, # 0 to infinity, where 0 is instant reload time
}

const GUN_STATS: Dictionary = {
    GunType.HANDGUN: {
        GunStat.PRECISION_HIP: 0.9,
        GunStat.PRECISION_AIM: 1.0,
        GunStat.RECOIL: 0.3,
        GunStat.MAGAZINE_COUNT: 5,
        GunStat.MAGAZINE_SIZE: 10,
        GunStat.RELOAD_TIME: 1.0,
    },
    GunType.SHOTGUN: {
        GunStat.PRECISION_HIP: 0,
        GunStat.PRECISION_AIM: 0.2,
        GunStat.RECOIL: 0.8,
        GunStat.MAGAZINE_COUNT: 10,
        GunStat.MAGAZINE_SIZE: 2,
        GunStat.RELOAD_TIME: 2.0,
    },
    GunType.RIFLE: {
        GunStat.PRECISION_HIP: 0.2,
        GunStat.PRECISION_AIM: 2.5,
        GunStat.RECOIL: 0.5,
        GunStat.MAGAZINE_COUNT: 3,
        GunStat.MAGAZINE_SIZE: 30,
        GunStat.RELOAD_TIME: 1.5,
    }
}