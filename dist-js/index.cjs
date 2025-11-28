let __tauri_apps_api_core = require("@tauri-apps/api/core");

//#region node_modules/.pnpm/@rollup+plugin-typescript@11.1.6_rollup@2.79.2_tslib@2.8.1_typescript@5.9.3/node_modules/tslib/tslib.es6.js
function __classPrivateFieldGet(receiver, state, kind, f) {
	if (kind === "a" && !f) throw new TypeError("Private accessor was defined without a getter");
	if (typeof state === "function" ? receiver !== state || !f : !state.has(receiver)) throw new TypeError("Cannot read private member from an object whose class did not declare it");
	return kind === "m" ? f : kind === "a" ? f.call(receiver) : f ? f.value : state.get(receiver);
}
function __classPrivateFieldSet(receiver, state, value, kind, f) {
	if (kind === "m") throw new TypeError("Private method is not writable");
	if (kind === "a" && !f) throw new TypeError("Private accessor was defined without a setter");
	if (typeof state === "function" ? receiver !== state || !f : !state.has(receiver)) throw new TypeError("Cannot write private member to an object whose class did not declare it");
	return kind === "a" ? f.call(receiver, value) : f ? f.value = value : state.set(receiver, value), value;
}

//#endregion
//#region guest-js/ads/common.ts
var _MobileAd_created, _MobileAd_init;
async function isPrivacyOptionsRequired() {
	return (await (0, __tauri_apps_api_core.invoke)("plugin:admob|isPrivacyOptionsRequired")).isPrivacyOptionsRequired;
}
async function showPrivacyOptionsForm() {
	await (0, __tauri_apps_api_core.invoke)("plugin:admob|showPrivacyOptionsForm");
}
var MobileAd = class MobileAd {
	constructor(opts) {
		_MobileAd_created.set(this, false);
		_MobileAd_init.set(this, null);
		this.opts = opts;
		this.id = MobileAd.nextId();
		MobileAd.allAdds[this.id] = this;
	}
	static nextId() {
		return MobileAd.idCounter++;
	}
	get adUnitId() {
		return this.opts.adUnitId;
	}
	async isLoaded() {
		await this.init();
		return await (0, __tauri_apps_api_core.invoke)("plugin:admob|adIsLoaded", { id: this.id });
	}
	async load() {
		await this.init();
		await (0, __tauri_apps_api_core.invoke)("plugin:admob|adLoad", {
			...this.opts,
			id: this.id
		});
	}
	async show() {
		await this.init();
		await (0, __tauri_apps_api_core.invoke)("plugin:admob|adShow", { id: this.id });
	}
	async hide() {
		await this.init();
		await (0, __tauri_apps_api_core.invoke)("plugin:admob|adHide", { id: this.id });
	}
	async init() {
		if (__classPrivateFieldGet(this, _MobileAd_created, "f")) return;
		if (__classPrivateFieldGet(this, _MobileAd_init, "f") === null) {
			const cls = this.constructor.cls ?? this.constructor.name;
			await (0, __tauri_apps_api_core.invoke)("plugin:admob|adCreate", {
				...this.opts,
				id: this.id,
				cls
			});
		}
		await __classPrivateFieldGet(this, _MobileAd_init, "f");
		__classPrivateFieldSet(this, _MobileAd_created, true, "f");
	}
};
_MobileAd_created = /* @__PURE__ */ new WeakMap(), _MobileAd_init = /* @__PURE__ */ new WeakMap();
MobileAd.allAdds = {};
MobileAd.idCounter = 0;

//#endregion
//#region guest-js/ads/banner.ts
var _BannerAd_loaded;
var BannerAd = class extends MobileAd {
	constructor(opts) {
		super({
			position: "bottom",
			...opts
		});
		_BannerAd_loaded.set(this, false);
	}
	isLoaded() {
		return super.isLoaded();
	}
	async load() {
		await super.load();
		__classPrivateFieldSet(this, _BannerAd_loaded, true, "f");
	}
	async show() {
		if (!__classPrivateFieldGet(this, _BannerAd_loaded, "f")) await this.load();
		await super.show();
	}
	hide() {
		return super.hide();
	}
};
_BannerAd_loaded = /* @__PURE__ */ new WeakMap();
BannerAd.cls = "BannerAd";

//#endregion
//#region guest-js/ads/interstitial.ts
var InterstitialAd = class extends MobileAd {
	isLoaded() {
		return super.isLoaded();
	}
	async load() {
		return super.load();
	}
	async show() {
		return super.show();
	}
};
InterstitialAd.cls = "InterstitialAd";

//#endregion
//#region guest-js/ads/rewarded.ts
var RewardedAd = class extends MobileAd {
	isLoaded() {
		return super.isLoaded();
	}
	async load() {
		return super.load();
	}
	async show() {
		return super.show();
	}
};
RewardedAd.cls = "RewardedAd";
var RewardedInterstitialAd = class extends MobileAd {
	isLoaded() {
		return super.isLoaded();
	}
	async load() {
		return super.load();
	}
	async show() {
		return super.show();
	}
};
RewardedInterstitialAd.cls = "RewardedInterstitialAd";

//#endregion
exports.BannerAd = BannerAd;
exports.InterstitialAd = InterstitialAd;
exports.MobileAd = MobileAd;
exports.RewardedAd = RewardedAd;
exports.RewardedInterstitialAd = RewardedInterstitialAd;
exports.isPrivacyOptionsRequired = isPrivacyOptionsRequired;
exports.showPrivacyOptionsForm = showPrivacyOptionsForm;