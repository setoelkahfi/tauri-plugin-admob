import { MobileAd, type MobileAdOptions } from "./common";
import { PluginListener } from "@tauri-apps/api/core";
export declare class RewardedAd extends MobileAd<RewardedAdOptions> {
    static cls: string;
    isLoaded(): Promise<unknown>;
    load(): Promise<void>;
    show(): Promise<void>;
    onRewarded(handler: (payload: any) => void): Promise<PluginListener>;
}
export declare function onRewarded(handler: (payload: any) => void): Promise<PluginListener>;
export declare class RewardedInterstitialAd extends MobileAd<RewardedAdOptions> {
    static cls: string;
    isLoaded(): Promise<unknown>;
    load(): Promise<void>;
    show(): Promise<void>;
}
export interface RewardedAdOptions extends MobileAdOptions {
    serverSideVerification?: {
        userId?: string;
        customData?: string;
    };
}
