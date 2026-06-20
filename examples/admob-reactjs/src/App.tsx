import { useEffect, useState } from "react";
import reactLogo from "./assets/react.svg";
import {
  BannerAd,
  RewardedAd,
  showPrivacyOptionsForm,
} from "tauri-plugin-admob-api";
import "./App.css";

function App() {
  const [bannerAd, setBannerAd] = useState<BannerAd>();
  const [rewardedAd, setRewardedAd] = useState<RewardedAd>();

  const showBannerAd = async () => {
    await bannerAd?.show();
  };

  const showRewardedAd = async () => {
    try {
      await rewardedAd?.show();
      const rewardPromise = await rewardedAd?.onRewarded(async (reward) => {
        console.log("RewardedAd get reward callback:", JSON.stringify(reward));
      });
      console.log(rewardPromise?.event);
    } catch (e) {
      console.log(e);
    }
  };

  const loadAds = async () => {
    const bannerAd = new BannerAd({
      adUnitId: "ca-app-pub-3940256099942544/9214589741",
      position: "top",
    });

    const rewardedAd = new RewardedAd({
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
    });

    await bannerAd.load();
    await rewardedAd.load();

    setBannerAd(bannerAd);
    setRewardedAd(rewardedAd);
  };

  useEffect(() => {
    loadAds();
  });

  return (
    <main className="container">
      <h1>Welcome to Tauri + React</h1>

      <div className="row">
        <a href="https://vite.dev" target="_blank">
          <img src="/vite.svg" className="logo vite" alt="Vite logo" />
        </a>
        <a href="https://tauri.app" target="_blank">
          <img src="/tauri.svg" className="logo tauri" alt="Tauri logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <p>Click on the Tauri, Vite, and React logos to learn more.</p>

      <div className="row">
        <button onClick={showPrivacyOptionsForm}>Show Privacy Form</button>
      </div>
      <div className="row">
        <button onClick={showBannerAd}>Show Banner Ad</button>
      </div>
      <div className="row">
        <button onClick={showRewardedAd}>Show Rewarded Ad</button>
      </div>
    </main>
  );
}

export default App;
