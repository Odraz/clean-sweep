extends Node

enum Type {
    HANDGUN,
    SHOTGUN,
    RIFLE
}

enum Stat {
    PRECISION_HIP, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 15 pixels
    PRECISION_AIM, # 0 to 1, where 1 is 0 offset from base crosshair position and 0 is 10 pixels
    RANGE, # 0 to 1, where 0 is 0 range and 1 is 1300 pixels
    RECOIL, # 0 to 1, where 0 is 0 recoil and 1 is 40 pixels
    MAGAZINE_COUNT, # 0 to infinity, where 0 is infinite magazine count
    MAGAZINE_SIZE, # 0 to infinity, where 0 is infinite magazine size
    RELOAD_TIME, # 0 to infinity, where 0 is instant reload time
    SINGLE_SHOT_BULLET_COUNT,
    BURST_SHOT_COUNT,
}

const STATS: Dictionary = {
    Type.HANDGUN: {
        Stat.PRECISION_HIP: 0.9,
        Stat.PRECISION_AIM: 1.0,
        Stat.RANGE: 0.6,
        Stat.RECOIL: 0.3,
        Stat.MAGAZINE_COUNT: 5,
        Stat.MAGAZINE_SIZE: 10,
        Stat.RELOAD_TIME: 1.0,
        Stat.SINGLE_SHOT_BULLET_COUNT: 1,
        Stat.BURST_SHOT_COUNT: 1,

    },
    Type.SHOTGUN: {
        Stat.PRECISION_HIP: 0,
        Stat.PRECISION_AIM: 0.2,
        Stat.RANGE: 0.8,
        Stat.RECOIL: 0.8,
        Stat.MAGAZINE_COUNT: 10,
        Stat.MAGAZINE_SIZE: 2,
        Stat.RELOAD_TIME: 2.0,
        Stat.SINGLE_SHOT_BULLET_COUNT: 3,
        Stat.BURST_SHOT_COUNT: 1,
    },
    Type.RIFLE: {
        Stat.PRECISION_HIP: 0.2,
        Stat.PRECISION_AIM: 2.5,
        Stat.RANGE: 1,
        Stat.RECOIL: 0.5,
        Stat.MAGAZINE_COUNT: 3,
        Stat.MAGAZINE_SIZE: 30,
        Stat.RELOAD_TIME: 1.5,
        Stat.SINGLE_SHOT_BULLET_COUNT: 1,
        Stat.BURST_SHOT_COUNT: 3,
    }
}