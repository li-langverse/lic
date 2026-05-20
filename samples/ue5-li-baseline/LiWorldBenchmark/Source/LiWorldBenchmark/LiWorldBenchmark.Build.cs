using UnrealBuildTool;

public class LiWorldBenchmark : ModuleRules
{
	public LiWorldBenchmark(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
		PublicDependencyModuleNames.AddRange(
			new[] { "Core", "CoreUObject", "Engine", "MassEntity", "MassCommon" });
	}
}
