import { MobileAd, type MobileAdOptions } from "./common";
import { addPluginListener, PluginListener } from "@tauri-apps/api/core";

export class RewardedAd extends MobileAd<RewardedAdOptions> {
	static cls = "RewardedAd";

	isLoaded() {
		return super.isLoaded();
	}

	async load() {
		return super.load();
	}

	async show() {
		return super.show();
	}

	async onRewarded(
	  handler: (payload: any) => void
  ): Promise<PluginListener> {
    return await addPluginListener(
      'admob',
      'rewarded_reward',
      handler
    );
  }
}

export async function onRewarded(
  handler: (payload: any) => void
): Promise<PluginListener> {
  return await addPluginListener(
    'admob',
    'rewarded/reward',
    handler
  );
}

export class RewardedInterstitialAd extends MobileAd<RewardedAdOptions> {
	static cls = "RewardedInterstitialAd";

	isLoaded() {
		return super.isLoaded();
	}

	async load() {
		return super.load();
	}

	async show() {
		return super.show();
	}
}

export interface RewardedAdOptions extends MobileAdOptions {
	serverSideVerification?: {
		userId?: string;
		customData?: string;
	};
}
