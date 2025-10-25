using System.Reflection;
using SPT.Reflection.Patching;
using Comfort.Common;
using EFT;
using UnityEngine;

namespace AmandsSense
{
    public class GameWorldStartedPatch : ModulePatch
    {
        protected override MethodBase GetTargetMethod()
        {
            return typeof(GameWorld).GetMethod(nameof(GameWorld.OnGameStarted));
        }

        [PatchPostfix]
        public static void PatchPostfix(GameWorld __instance)
        {
            try
            {
                if (__instance == null)
                {
                    AmandsSensePlugin.LogSource.LogError("[AmandsSense] GameWorld instance is null!");
                    return;
                }

                // Add AmandsSenseClass component to GameWorld GameObject
                AmandsSensePlugin.AmandsSenseClassComponent = __instance.gameObject.AddComponent<AmandsSenseClass>();

                // Add AudioSource component
                AmandsSenseClass.SenseAudioSource = __instance.gameObject.AddComponent<AudioSource>();
            }
            catch (System.Exception ex)
            {
                AmandsSensePlugin.LogSource.LogError($"[AmandsSense] Exception in GameWorldStartedPatch: {ex.Message}\n{ex.StackTrace}");
                throw;
            }
        }
    }
}
