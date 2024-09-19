extends Node

enum GunType {
    PISTOL,
    SHOTGUN,
    RIFLE
}

enum GunStat {
    PRECISION_HIP, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 15 pixels
    PRECISION_AIM, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 10 pixels
    RECOIL, # 0 to 1, where 0 is 0 recoil and 1 is 40 pixels
}

# Dictionary of gun stats
const GUN_STATS: Dictionary = {
    GunType.PISTOL: {
        GunStat.PRECISION_HIP: 1.0,
        GunStat.PRECISION_AIM: 0.8,
        GunStat.RECOIL: 0.3,
    },
    GunType.SHOTGUN: {
        GunStat.PRECISION_HIP: 0.4,
        GunStat.PRECISION_AIM: 0.7,
        GunStat.RECOIL: 0.8,
    },
    GunType.RIFLE: {
        GunStat.PRECISION_HIP: 0.4,
        GunStat.PRECISION_AIM: 1.0,
        GunStat.RECOIL: 0.7,
    }
}