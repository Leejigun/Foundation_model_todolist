//
//  GEMINI.md
//  Foundation_model_todolist
//
//  Created by bimo.ez on 9/6/25.
//

## 개요
Apple의 새로운 on-device AI Foundation Model 을 스터디 하기 위해서 진행하는 프로젝트 입니다.

## 목표
Todolist를 SwiftUI 기반으로

## 스펙

### Apple Foundation Models 사용법

이 프로젝트에서 Apple의 온디바이스 AI인 Foundation Models 프레임워크를 사용하는 주요 패턴은 다음과 같습니다.

1.  **프레임워크 임포트**:
    ```swift
    import FoundationModels
    ```

2.  **모델 가용성 확인**:
    모델을 사용하기 전에 기기에서 사용 가능한지 확인하는 것이 좋습니다.
    ```swift
    let systemModel = SystemLanguageModel.default
    guard systemModel.isAvailable else {
        print("Foundation Model unavailable: \(systemModel.availability)")
        // 모델 사용 불가 시 대체 로직 또는 사용자에게 안내
        return // 또는 throw
    }
    ```

3.  **`LanguageModelSession` 초기화**:
    LLM과의 상호작용은 `LanguageModelSession`을 통해 이루어집니다. 이 세션은 모델의 전반적인 행동을 정의하는 `systemPrompt`와, 모델이 호출할 수 있는 `Tool`들을 인자로 받습니다.
    ```swift
    // 텍스트 교정처럼 특정 도구가 필요 없는 경우 tools는 빈 배열로 초기화
    let session = LanguageModelSession(tools: []) {
        """
        당신은 매우 정확한 텍스트 교정 AI입니다. 제공된 텍스트의 문법 오류, 철자 오류, 어색한 구문을 교정하는 것이 당신의 임무입니다.
        원본 텍스트의 언어를 유지하세요.
        교정된 텍스트만 반환하며, 따옴표, 구분자 또는 추가 설명은 포함하지 마세요.
        """
    }
    ```

4.  **모델에 프롬프트 전송 및 응답 스트리밍**:
    `session.streamResponse(to: prompt)`를 사용하여 모델에 요청을 보내고 응답을 스트리밍 방식으로 받습니다.
    ```swift
    let userPrompt = "교정할 텍스트: \"\(text)\"" // 사용자에게서 받은 텍스트를 포함한 프롬프트
    let stream = session.streamResponse(to: userPrompt)

    var generatedText = ""
    for try await part in stream {
        if let textPart = part.text { // 또는 part.content 등 실제 타입에 따라 접근
            generatedText += textPart
        }
    }
    // generatedText에 모델의 응답이 최종적으로 담깁니다.
    ```
    *주의*: `part.text` 또는 `part.content`는 `streamResponse`의 `generating` 파라미터 유무에 따라 달라질 수 있습니다. `generating: SomeGenerableType.self`를 사용하면 `part`는 해당 `Generable` 타입의 부분적인 스냅샷을 반환합니다.

5.  **구조화된 출력 (`@Generable`, `@Guide`)**:
    모델로부터 특정 Swift `struct` 형태로 응답을 받고 싶을 때 사용합니다.
    ```swift
    import FoundationModels

    @Generable
    struct MyStructuredOutput {
        @Guide(description: "생성될 데이터에 대한 설명")
        let propertyName: String
    }

    // 사용 예시:
    // let stream = session.streamResponse(to: prompt, generating: MyStructuredOutput.self)
    // for try await partial in stream {
    //     // partial은 MyStructuredOutput의 부분적인 인스턴스가 됩니다.
    // }
    ```

### 클린 아키텍처 (Clean Architecture)


이 프로젝트는 엄격한 클린 아키텍처를 따르며, 계층은 `Domain`, `Data`, `Presentation` 세 가지로 분리됩니다.

-   **의존성 규칙**: 모든 의존성은 외부에서 내부를 향합니다. (`Presentation` -> `Domain` <- `Data`)

#### 1. Domain 계층
-   **설명**: 앱의 가장 핵심적인 비즈니스 로직을 포함하며, 다른 어떤 계층에도 의존하지 않는 순수한 영역입니다.
-   **`Entities`**: 앱의 핵심 비즈니스 모델 (e.g., `TodoItem`). 프레임워크에 독립적인 순수 Swift 객체입니다.
-   **`UseCases`**: 애플리케이션의 특정 비즈니스 로직을 캡슐화합니다. (e.g., `AddTodoUseCase`).
-   **`Repositories` (Interface)**: 데이터 소스에 대한 규칙(Protocol)을 정의합니다. `Domain` 계층은 이 인터페이스에만 의존합니다.

#### 2. Data 계층
-   **설명**: 데이터의 출처(네트워크, 데이터베이스 등)를 관리하고, `Domain` 계층의 Repository 인터페이스를 구현합니다.
-   **`DataModels`**: 특정 데이터 소스에 종속적인 모델입니다. (e.g., SwiftData의 `@Model`이 적용된 `TodoItemDataModel`).
-   **`Repositories` (Implementation)**: `Domain`의 Repository 인터페이스를 실제로 구현하는 클래스입니다. SwiftData, CoreData, API 등을 사용하여 데이터를 처리합니다.
-   **`Mappers`**: `Data` 계층의 `DataModel`과 `Domain` 계층의 `Entity`를 서로 변환하는 역할을 합니다.

#### 3. Presentation 계층
-   **설명**: UI(View)와 UI의 상태(ViewModel)를 관리합니다. `Domain` 계층에만 의존합니다.
-   **`Features`**: 기능별로 `View`와 `ViewModel`을 그룹화하여 관리합니다.
    -   **`ViewModel`**: `Domain`의 `UseCase`를 사용하여 비즈니스 로직을 실행하고, 그 결과를 `View`에 맞게 가공하여 전달합니다.
    -   **`View`**: `ViewModel`로부터 데이터를 받아 화면에 그리고, 사용자 입력을 `ViewModel`에 전달합니다.

---

### 부가 스펙

-   **색상 관리**:
    -   앱의 전반적인 테마(primary, secondary 등)와 관련된 색상은 `config/themes`에서 관리합니다.
    -   테마와 무관하게 고정적으로 사용되는 특정 색상(예: 성공, 오류)은 `constants/app_colors` 파일에 상수로 정의하여 사용합니다.
-   **코드 스타일**:
    -   SOLID 원칙, 의미 있는 변수명, 작은 함수, 중복 제거 등 클린 코드 원칙을 준수합니다.
-   **기술 스택**:
    -   SwiftUI + Swift Concurrency
    -   SwiftData (Data 계층에서 사용)

## On-device AI 기능 아이디어

블로그 게시물에서 논의된 6가지 핵심 AI 활용 사례를 기반으로 이 TodoList 앱에 적용할 수 있는 기능 아이디어입니다.

### 1. 요약 (Summarization) 기반
*   **기능명**: **오늘의 브리핑**
*   **설명**: 사용자가 앱을 켰을 때, 오늘 해야 할 일(또는 밀린 일) 목록을 분석하여 "오늘 회의 2건과 장보기 등 총 5개의 할 일이 있습니다. 특히 '프로젝트 기획안 제출'은 마감이 임박했습니다."와 같이 자연어 문장으로 요약해 줍니다.
*   **기대 효과**: 하루의 작업을 한눈에 파악하고 우선순위를 빠르게 인지할 수 있습니다.

### 2. 추출 (Extraction) 기반
*   **기능명**: **스마트 할 일 추가**
*   **설명**: 사용자가 "내일 오후 2시에 강남역에서 클라이언트 미팅"이라고 통문장으로 입력하면, AI가 문장에서 핵심 정보를 자동으로 추출하여 할 일 제목(`클라이언트 미팅`), 날짜(`내일`), 시간(`오후 2시`), 장소(`강남역`) 필드에 자동으로 입력해 줍니다.
*   **기대 효과**: 여러 필드를 직접 입력할 필요 없이, 대화하듯 자연스럽게 할 일을 추가하여 사용자 경험을 크게 향상시킵니다.

### 3. 분류 (Classification) 기반
*   **기능명**: **자동 카테고리 분류**
*   **설명**: 사용자가 "주간 보고서 작성"이라는 할 일을 추가하면 AI가 '업무' 카테고리로, "우유, 계란 사기"를 추가하면 '장보기' 또는 '집안일' 카테고리로 자동 분류해 줍니다. 카테고리는 사용자가 미리 설정해 둘 수 있습니다.
*   **기대 효과**: 수동으로 카테고리를 지정하는 번거로움을 없애고, 할 일 목록을 자동으로 깔끔하게 정리합니다.

### 4. 태깅 (Tagging) 기반
*   **기능명**: **AI 태그 추천**
*   **설명**: 할 일의 내용을 분석하여 관련 태그를 자동으로 추천합니다. 예를 들어, "알고리즘 문제 풀기"에는 `#코딩`, `#공부`를, "헬스장 가기"에는 `#운동`, `#건강` 태그를 추천해 줍니다.
*   **기대 효과**: 나중에 특정 태그가 붙은 할 일만 모아보거나 검색하기 용이해집니다.

### 5. 구성 (Composition) 기반
*   **기능명**: **예상 소요 시간 제안**
*   **설명**: 할 일의 제목을 기반으로 예상 소요 시간을 제안합니다. 예를 들어, "기획안 작성"에는 '약 2시간'을, "이메일 답장"에는 '약 15분'을 제안하여 사용자가 시간 계획을 세우는 데 도움을 줍니다. (과거 비슷한 작업에 걸린 시간을 학습하여 더 정확해질 수 있습니다.)
*   **기대 효과**: 사용자가 하루의 작업량을 가늠하고 더 현실적인 시간 계획을 세울 수 있도록 돕습니다.

### 6. 교정 (Revision) 기반
*   **기능명**: **할 일 제목 자동 교정**
*   **설명**: 사용자가 입력한 할 일의 오타를 자동으로 수정하거나, 더 명확한 표현으로 다듬어 줍니다. 예를 들어, "책읽기 내일저녁에" -> "내일 저녁에 책 읽기" 와 같이 문법과 띄어쓰기를 교정합니다.
*   **기대 효과**: 할 일 목록의 가독성과 통일성을 높여줍니다.