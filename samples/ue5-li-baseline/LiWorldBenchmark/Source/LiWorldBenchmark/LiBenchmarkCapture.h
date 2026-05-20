#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "LiBenchmarkCapture.generated.h"

UCLASS()
class ALiBenchmarkGameMode : public AGameModeBase
{
	GENERATED_BODY()
public:
	virtual void StartPlay() override;
};
