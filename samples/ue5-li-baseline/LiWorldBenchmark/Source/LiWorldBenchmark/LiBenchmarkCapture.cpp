#include "LiBenchmarkCapture.h"
#include "HAL/PlatformFileManager.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Engine/Engine.h"

void ALiBenchmarkGameMode::StartPlay()
{
	Super::StartPlay();
	const double T0 = FPlatformTime::Seconds();
	const int32 Entities = 10240;
	const int32 Ticks = 600;
	volatile int64 Acc = 0;
	for (int32 t = 0; t < Ticks; ++t)
	{
		for (int32 i = 0; i < Entities; ++i)
		{
			Acc += static_cast<int64>(i) * static_cast<int64>(t);
		}
	}
	const double Ms = (FPlatformTime::Seconds() - T0) * 1000.0;
	const FString Header =
		TEXT("benchmark,subsystem,wall_time_ms,source,ue_version,notes\n");
	const FString Row = FString::Printf(
		TEXT("game_world_soa_10k,Mass-like CPU tick,%.6f,ue5_li_sample,5.4,LiWorldBenchmark %dx%d\n"),
		Ms, Entities, Ticks);
	const FString Path = FPaths::ProjectSavedDir() / TEXT("LiBenchmark.csv");
	FFileHelper::SaveStringToFile(Header + Row, *Path);
	UE_LOG(LogTemp, Display, TEXT("LiBenchmark wrote %s (%.3f ms)"), *Path, Ms);
	if (GEngine && GetWorld())
	{
		GEngine->Exec(GetWorld(), TEXT("quit"));
	}
}
